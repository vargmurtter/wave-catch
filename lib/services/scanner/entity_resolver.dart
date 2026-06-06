import 'package:path/path.dart' as p;

import 'package:music_player/services/scanner/album_grouping.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/scanner/file_discovery.dart';
import 'package:music_player/services/scanner/id_generator.dart';
import 'package:music_player/services/scanner/raw_track_metadata.dart';
import 'package:music_player/services/scanner/scan_rules.dart';

class ResolvedTrack {
  const ResolvedTrack({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumTitle,
    required this.parentDir,
    required this.durationMs,
    required this.fileModifiedMs,
    this.albumArtistName,
    this.trackNumber,
    this.genre,
    this.format,
    this.year,
    this.embeddedCoverBytes,
    this.embeddedCoverMimeType,
  });

  final String id;
  final String filePath;
  final String title;
  final String artistId;
  final String artistName;
  final String albumId;
  final String albumTitle;
  final String parentDir;
  final int durationMs;
  final int fileModifiedMs;
  final String? albumArtistName;
  final int? trackNumber;
  final String? genre;
  final String? format;
  final int? year;
  final List<int>? embeddedCoverBytes;
  final String? embeddedCoverMimeType;
}

class EntityResolver {
  ResolvedTrack resolve({
    required DiscoveredAudioFile file,
    required RawTrackMetadata metadata,
    required AlbumGroupingStrategy strategy,
  }) {
    final artistName = metadata.artist ?? kUnknownArtist;
    final albumTitle = metadata.album ??
        (p.basename(file.parentDir).trim().isNotEmpty
            ? p.basename(file.parentDir)
            : kUnknownAlbum);
    final title = metadata.title ?? file.fileNameWithoutExt;
    final extension = file.filePath.split('.').last.toLowerCase();

    return ResolvedTrack(
      id: trackIdFor(file.filePath),
      filePath: file.filePath,
      title: title,
      artistId: artistIdFor(artistName),
      artistName: artistName,
      albumId: computeAlbumId(
        strategy: strategy,
        albumTitle: albumTitle,
        parentDir: file.parentDir,
        albumArtist: metadata.albumArtist,
        trackArtist: artistName,
        year: metadata.year,
      ),
      albumTitle: albumTitle,
      parentDir: file.parentDir,
      durationMs: metadata.durationMs,
      fileModifiedMs: DateTime.now().millisecondsSinceEpoch,
      albumArtistName: metadata.albumArtist,
      trackNumber: metadata.trackNumber,
      genre: metadata.genre,
      format: extension,
      year: metadata.year,
      embeddedCoverBytes: metadata.embeddedCoverBytes,
      embeddedCoverMimeType: metadata.embeddedCoverMimeType,
    );
  }
}
