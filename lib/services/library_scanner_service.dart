import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/metadata_override_repository.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/metadata_override_applier.dart';
import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/services/scanner/cover_art_resolver.dart';
import 'package:music_player/services/scanner/entity_resolver.dart';
import 'package:music_player/services/scanner/file_discovery.dart';
import 'package:music_player/services/scanner/id_generator.dart';
import 'package:music_player/services/scanner/library_persister.dart';
import 'package:music_player/services/scanner/metadata_extractor.dart';
import 'package:music_player/services/scanner/raw_track_metadata.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/services/settings_service.dart';

class LibraryScannerService {
  LibraryScannerService({
    required SettingsService settingsService,
    required LibraryRepository libraryRepository,
    MetadataOverrideRepository? overrideRepository,
    MetadataOverrideApplier? overrideApplier,
    FileDiscovery? fileDiscovery,
    MetadataExtractor? metadataExtractor,
    EntityResolver? entityResolver,
    CoverArtResolver? coverArtResolver,
    LibraryPersister? libraryPersister,
  })  : _settingsService = settingsService,
        _libraryRepository = libraryRepository,
        _overrideRepository = overrideRepository ?? MetadataOverrideRepository(),
        _overrideApplier = overrideApplier ?? MetadataOverrideApplier(),
        _fileDiscovery = fileDiscovery ?? FileDiscovery(),
        _metadataExtractor = metadataExtractor ?? MetadataExtractor(),
        _entityResolver = entityResolver ?? EntityResolver(),
        _coverArtResolver = coverArtResolver ?? CoverArtResolver(),
        _libraryPersister =
            libraryPersister ?? LibraryPersister(libraryRepository);

  final SettingsService _settingsService;
  final LibraryRepository _libraryRepository;
  final MetadataOverrideRepository _overrideRepository;
  final MetadataOverrideApplier _overrideApplier;
  final FileDiscovery _fileDiscovery;
  final MetadataExtractor _metadataExtractor;
  final EntityResolver _entityResolver;
  final CoverArtResolver _coverArtResolver;
  final LibraryPersister _libraryPersister;

  Future<ScanResult> scan(
    ScanJob job, {
    ScanProgressCallback? onProgress,
  }) async {
    final musicRoot = job.musicRoot;
    if (!Directory(musicRoot).existsSync()) {
      throw StateError('Music library folder does not exist: $musicRoot');
    }

    _libraryRepository.open(musicRoot);

    final editMode = _settingsService.metadataEditMode;
    final overrides = await _overrideRepository.loadTrackOverrides(musicRoot);

    final discovered = _fileDiscovery.discover(musicRoot);
    final total = discovered.length;
    final resolvedTracks = <ResolvedTrack>[];
    final errors = <String>[];

    for (var index = 0; index < discovered.length; index++) {
      final file = discovered[index];
      onProgress?.call(
        ScanProgress(
          processed: index,
          total: total,
          currentPath: file.filePath,
        ),
      );

      try {
        final stat = File(file.filePath).statSync();
        final trackId = trackIdFor(file.filePath);
        var metadata = await _metadataExtractor.extract(file.filePath);
        final override = overrides[trackId];

        metadata = _applyOverrides(
          metadata: metadata,
          override: override,
          editMode: editMode,
          musicRoot: musicRoot,
        );

        final resolved = _entityResolver.resolve(
          file: file,
          metadata: metadata,
          strategy: job.albumGroupingStrategy,
        );
        resolvedTracks.add(
          ResolvedTrack(
            id: resolved.id,
            filePath: resolved.filePath,
            title: resolved.title,
            artistId: resolved.artistId,
            artistName: resolved.artistName,
            albumId: resolved.albumId,
            albumTitle: resolved.albumTitle,
            parentDir: resolved.parentDir,
            durationMs: metadata.durationMs,
            fileModifiedMs: stat.modified.millisecondsSinceEpoch,
            albumArtistName: resolved.albumArtistName,
            featuredArtists: resolved.featuredArtists,
            trackNumber: resolved.trackNumber,
            genre: resolved.genre,
            format: resolved.format,
            year: resolved.year,
            discNumber: resolved.discNumber,
            embeddedCoverBytes: metadata.embeddedCoverBytes,
            embeddedCoverMimeType: metadata.embeddedCoverMimeType,
            overrideCoverPath: metadata.overrideCoverPath,
          ),
        );
      } catch (error) {
        errors.add('${file.filePath}: $error');
      }
    }

    onProgress?.call(ScanProgress(processed: total, total: total));

    final library = _coverArtResolver.resolve(
      musicRoot: musicRoot,
      tracks: resolvedTracks,
    );

    _libraryPersister.persist(library);

    if (_settingsService.musicLibraryPath != musicRoot) {
      await _settingsService.setMusicLibraryPath(musicRoot);
    }

    return ScanResult(
      trackCount: library.tracks.length,
      artistCount: library.artists.length,
      albumCount: library.albums.length,
      errors: errors,
    );
  }

  RawTrackMetadata _applyOverrides({
    required RawTrackMetadata metadata,
    required TrackMetadataOverride? override,
    required MetadataEditMode editMode,
    required String musicRoot,
  }) {
    if (override == null) return metadata;

    var result = editMode == MetadataEditMode.override
        ? _overrideApplier.applyFull(metadata, override)
        : _overrideApplier.applyFeaturedOnly(metadata, override);

    if (result.overrideCoverPath != null) {
      final coverPath = _resolveCoverPath(musicRoot, result.overrideCoverPath!);
      result = result.copyWith(overrideCoverPath: coverPath);
    }

    return result;
  }

  String _resolveCoverPath(String musicRoot, String coverPath) {
    if (p.isAbsolute(coverPath)) return coverPath;
    return p.normalize(p.join(musicRoot, coverPath));
  }
}
