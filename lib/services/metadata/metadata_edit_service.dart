import 'package:path/path.dart' as p;

import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/metadata_file_writer.dart';
import 'package:music_player/repositories/metadata_override_repository.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/scanner/album_grouping.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/scanner/cover_art_resolver.dart';
import 'package:music_player/services/scanner/id_generator.dart';
import 'package:music_player/services/scanner/scan_rules.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/track.dart';

class MetadataEditService {
  MetadataEditService({
    required SettingsService settingsService,
    required LibraryRepository libraryRepository,
    required MetadataOverrideRepository overrideRepository,
    required MetadataFileWriter fileWriter,
    required CoverArtResolver coverArtResolver,
  })  : _settingsService = settingsService,
        _libraryRepository = libraryRepository,
        _overrideRepository = overrideRepository,
        _fileWriter = fileWriter,
        _coverArtResolver = coverArtResolver;

  final SettingsService _settingsService;
  final LibraryRepository _libraryRepository;
  final MetadataOverrideRepository _overrideRepository;
  final MetadataFileWriter _fileWriter;
  final CoverArtResolver _coverArtResolver;

  Future<TrackMetadataEditResult> updateTrackMetadata({
    required String trackId,
    required TrackMetadataEdit changes,
  }) async {
    _validate(changes);

    final musicRoot = _settingsService.musicLibraryPath;
    if (musicRoot == null) {
      throw MetadataEditException('Папка с музыкой не выбрана');
    }

    _libraryRepository.open(musicRoot);
    final track = _libraryRepository.getTrackById(trackId);
    if (track == null) {
      throw MetadataEditException('Трек не найден');
    }

    final mode = _settingsService.metadataEditMode;
    final now = DateTime.now().millisecondsSinceEpoch;
    var coverPath = track.coverPath;

    if (changes.newCoverImagePath != null) {
      coverPath = await _saveCustomCover(
        musicRoot: musicRoot,
        trackId: trackId,
        imagePath: changes.newCoverImagePath!,
      );
    }

    final relativeCoverPath = coverPath == null
        ? null
        : p.isWithin(musicRoot, coverPath)
            ? p.relative(coverPath, from: musicRoot)
            : coverPath;

    if (mode == MetadataEditMode.inFile) {
      final coverData = changes.newCoverImagePath != null
          ? await _fileWriter.readCoverBytes(changes.newCoverImagePath!)
          : null;
      await _fileWriter.writeMerged(
        filePath: track.filePath,
        changes: changes,
        coverBytes: coverData?.bytes,
        coverMimeType: coverData?.mimeType,
      );
      await _overrideRepository.upsertFeaturedArtists(
        musicRoot,
        trackId,
        changes.featuredArtists,
      );
    } else {
      await _overrideRepository.upsert(
        musicRoot,
        trackId,
        changes.toOverride(
          coverPath: relativeCoverPath,
          updatedAtMs: now,
        ),
      );
    }

    final updatedTrack = _applyDatabaseUpdate(
      track: track,
      changes: changes,
      coverPath: coverPath,
    );

    return TrackMetadataEditResult(track: updatedTrack);
  }

  void _validate(TrackMetadataEdit changes) {
    if (changes.title.trim().isEmpty) {
      throw MetadataEditException('Укажите название трека');
    }
    if (changes.artist.trim().isEmpty) {
      throw MetadataEditException('Укажите исполнителя');
    }
    if (changes.album.trim().isEmpty) {
      throw MetadataEditException('Укажите альбом');
    }
  }

  Future<String?> _saveCustomCover({
    required String musicRoot,
    required String trackId,
    required String imagePath,
  }) async {
    final coverData = await _fileWriter.readCoverBytes(imagePath);
    if (coverData == null) {
      throw MetadataEditException('Не удалось прочитать файл обложки');
    }

    final coversDir = p.join(musicRoot, kAppDataDirName, kEmbeddedCoversDirName);
    return _coverArtResolver.saveEmbeddedCover(
      coversDir: coversDir,
      trackId: '${trackId}_custom',
      bytes: coverData.bytes,
      mimeType: coverData.mimeType,
    );
  }

  Track _applyDatabaseUpdate({
    required TrackRecord track,
    required TrackMetadataEdit changes,
    required String? coverPath,
  }) {
    final strategy = _settingsService.albumGroupingStrategy;
    final artistName = changes.artist.trim();
    final albumTitle = changes.album.trim();
    final artistId = artistIdFor(artistName);
    final parentDir = p.dirname(track.filePath);
    final albumId = computeAlbumId(
      strategy: strategy,
      albumTitle: albumTitle,
      parentDir: parentDir,
      albumArtist: changes.albumArtist,
      trackArtist: artistName,
      year: changes.year,
    );

    final albumArtistId = _resolveAlbumArtistId(
      strategy: strategy,
      trackArtistId: artistId,
      trackArtistName: artistName,
      albumArtistName: changes.albumArtist,
    );

    _libraryRepository.upsertArtist(
      ArtistRecord(id: artistId, name: artistName),
    );
    _libraryRepository.upsertArtist(
      ArtistRecord(id: albumArtistId.id, name: albumArtistId.name),
    );
    _libraryRepository.upsertAlbum(
      AlbumRecord(
        id: albumId,
        title: albumTitle,
        artistId: albumArtistId.id,
        year: changes.year,
        coverPath: coverPath,
      ),
    );

    final updatedRecord = TrackRecord(
      id: track.id,
      filePath: track.filePath,
      title: changes.title.trim(),
      artistId: artistId,
      albumId: albumId,
      durationMs: track.durationMs,
      indexedAtMs: track.indexedAtMs,
      trackNumber: changes.trackNumber,
      genre: changes.genre,
      format: track.format,
      bitrate: track.bitrate,
      coverPath: coverPath,
      fileModifiedMs: track.fileModifiedMs,
      featuredArtists: changes.featuredArtists,
      albumArtist: changes.albumArtist,
      discNumber: changes.discNumber,
    );
    _libraryRepository.updateTrack(updatedRecord);
    _libraryRepository.deleteOrphanedArtistsAndAlbums();

    final album = _libraryRepository.getAlbumById(albumId);
    return Track(
      id: updatedRecord.id,
      filePath: updatedRecord.filePath,
      title: updatedRecord.title,
      artist: artistName,
      artistId: updatedRecord.artistId,
      albumId: updatedRecord.albumId,
      album: album?.title ?? albumTitle,
      year: album?.year ?? changes.year,
      albumArtUrl: coverPath ?? album?.coverPath,
      duration: Duration(milliseconds: updatedRecord.durationMs),
      trackNumber: updatedRecord.trackNumber,
      genre: updatedRecord.genre,
      format: updatedRecord.format,
      bitrate: updatedRecord.bitrate,
      featuredArtists: updatedRecord.featuredArtists,
      albumArtist: updatedRecord.albumArtist,
      discNumber: updatedRecord.discNumber,
    );
  }

  AlbumArtistResolution _resolveAlbumArtistId({
    required AlbumGroupingStrategy strategy,
    required String trackArtistId,
    required String trackArtistName,
    required String? albumArtistName,
  }) {
    if (strategy == AlbumGroupingStrategy.byAlbumArtist) {
      final name = albumArtistName?.trim();
      if (name != null && name.isNotEmpty) {
        return AlbumArtistResolution(
          id: artistIdFor(name),
          name: name,
        );
      }
    }

    return AlbumArtistResolution(
      id: trackArtistId,
      name: trackArtistName,
    );
  }
}
