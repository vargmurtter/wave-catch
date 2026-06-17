import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/metadata_file_writer.dart';
import 'package:music_player/repositories/ytdlp_repository.dart';
import 'package:music_player/services/library_scanner_service.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/models/track.dart';

class TrackImportService {
  TrackImportService({
    required SettingsService settingsService,
    required LibraryRepository libraryRepository,
    required LibraryScannerService libraryScannerService,
    required LibraryService libraryService,
    required YtdlpRepository ytdlpRepository,
    required MetadataFileWriter metadataFileWriter,
    required ImportSourceRepository Function() importSourceRepositoryFactory,
    http.Client? httpClient,
  })  : _settingsService = settingsService,
        _libraryRepository = libraryRepository,
        _libraryScannerService = libraryScannerService,
        _libraryService = libraryService,
        _ytdlpRepository = ytdlpRepository,
        _metadataFileWriter = metadataFileWriter,
        _importSourceRepositoryFactory = importSourceRepositoryFactory,
        _httpClient = httpClient ?? http.Client();

  final SettingsService _settingsService;
  final LibraryRepository _libraryRepository;
  final LibraryScannerService _libraryScannerService;
  final LibraryService _libraryService;
  final YtdlpRepository _ytdlpRepository;
  final MetadataFileWriter _metadataFileWriter;
  final ImportSourceRepository Function() _importSourceRepositoryFactory;
  final http.Client _httpClient;

  static const _importsDirName = 'Imports';
  static const _singlesAlbumName = 'Singles';

  Future<Track> saveExploreTrack(ExploreTrack exploreTrack) async {
    final musicRoot = _settingsService.musicLibraryPath;
    if (musicRoot == null || musicRoot.isEmpty) {
      throw StateError('Music library folder is not configured');
    }

    _libraryRepository.open(musicRoot);
    final existing = _importSourceRepositoryFactory()
        .getByVideoId(exploreTrack.videoId);
    if (existing != null) {
      final record = _libraryRepository.getTrackByFilePath(existing.filePath);
      if (record != null) {
        return _libraryService.getTrackById(record.id)!;
      }
    }

    final outputPath = _buildOutputPath(
      musicRoot: musicRoot,
      artist: exploreTrack.artist,
      title: exploreTrack.title,
    );

    final downloadedPath = await _ytdlpRepository.downloadAudio(
      watchUrl: exploreTrack.watchUrl,
      outputPath: outputPath,
    );

    List<int>? coverBytes;
    final thumbUrl = exploreTrack.thumbnailUrl;
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      try {
        final response = await _httpClient.get(Uri.parse(thumbUrl));
        if (response.statusCode == 200) {
          coverBytes = response.bodyBytes;
        }
      } on Object {
        coverBytes = null;
      }
    }

    await _metadataFileWriter.writeMerged(
      filePath: downloadedPath,
      changes: TrackMetadataEdit(
        title: exploreTrack.title,
        artist: exploreTrack.artist,
        featuredArtists: exploreTrack.artists
            .skip(1)
            .map((artist) => artist.name)
            .toList(),
        album: exploreTrack.album?.isNotEmpty == true
            ? exploreTrack.album!
            : _singlesAlbumName,
        albumArtist: exploreTrack.artist,
        year: exploreTrack.year,
      ),
      coverBytes: coverBytes,
    );

    final trackId = await _libraryScannerService.scanSingleFile(
      musicRoot: musicRoot,
      filePath: downloadedPath,
    );

    _importSourceRepositoryFactory().upsert(
      ImportSourceRecord(
        videoId: exploreTrack.videoId,
        filePath: downloadedPath,
        savedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    _libraryService.refreshOverrides();
    return _libraryService.getTrackById(trackId)!;
  }

  String _buildOutputPath({
    required String musicRoot,
    required String artist,
    required String title,
  }) {
    final safeArtist = _sanitizePathSegment(artist);
    final safeTitle = _sanitizePathSegment(title);
    final dir = Directory(p.join(musicRoot, _importsDirName, safeArtist));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    var filePath = p.join(dir.path, '$safeTitle.mp3');
    var counter = 2;
    while (File(filePath).existsSync()) {
      filePath = p.join(dir.path, '$safeTitle ($counter).mp3');
      counter++;
    }
    return filePath;
  }

  String _sanitizePathSegment(String value) {
    return value
        .replaceAll(RegExp(r'[/\\?%*:|"<>]'), '_')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
