import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:music_player/services/scanner/album_grouping.dart';
import 'package:music_player/services/scanner/entity_resolver.dart';
import 'package:music_player/services/scanner/scan_rules.dart';

class ResolvedLibrary {
  const ResolvedLibrary({
    required this.artists,
    required this.albums,
    required this.tracks,
  });

  final List<ResolvedArtist> artists;
  final List<ResolvedAlbum> albums;
  final List<ResolvedTrackWithCover> tracks;
}

class ResolvedArtist {
  const ResolvedArtist({
    required this.id,
    required this.name,
    this.coverPath,
  });

  final String id;
  final String name;
  final String? coverPath;
}

class ResolvedAlbum {
  const ResolvedAlbum({
    required this.id,
    required this.title,
    required this.artistId,
    this.year,
    this.coverPath,
  });

  final String id;
  final String title;
  final String artistId;
  final int? year;
  final String? coverPath;
}

class ResolvedTrackWithCover {
  const ResolvedTrackWithCover({
    required this.track,
    this.coverPath,
  });

  final ResolvedTrack track;
  final String? coverPath;
}

class CoverArtResolver {
  String? findCoverInDirectory(String dirPath) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) return null;

    late final List<FileSystemEntity> entities;
    try {
      entities = dir.listSync(followLinks: false);
    } catch (_) {
      return null;
    }

    for (final entity in entities) {
      if (entity is! File) continue;
      final extension =
          p.extension(entity.path).replaceFirst('.', '').toLowerCase();
      if (kCoverExtensions.contains(extension)) {
        return entity.path;
      }
    }
    return null;
  }

  String? saveEmbeddedCover({
    required String coversDir,
    required String trackId,
    required List<int> bytes,
    String? mimeType,
  }) {
    final extension = _extensionForMime(mimeType, bytes);
    final filePath = p.join(coversDir, '$trackId.$extension');
    try {
      File(filePath).writeAsBytesSync(bytes, flush: true);
      return filePath;
    } catch (_) {
      return null;
    }
  }

  ResolvedLibrary resolve({
    required String musicRoot,
    required List<ResolvedTrack> tracks,
  }) {
    final coversDir = p.join(musicRoot, kEmbeddedCoversDir);
    Directory(coversDir).createSync(recursive: true);

    final tracksWithCover = <ResolvedTrackWithCover>[];
    final albumTracks = <String, List<ResolvedTrackWithCover>>{};

    for (final track in tracks) {
      String? coverPath;

      if (track.embeddedCoverBytes != null &&
          track.embeddedCoverBytes!.isNotEmpty) {
        coverPath = saveEmbeddedCover(
          coversDir: coversDir,
          trackId: track.id,
          bytes: track.embeddedCoverBytes!,
          mimeType: track.embeddedCoverMimeType,
        );
      }

      coverPath ??= findCoverInDirectory(track.parentDir);

      final withCover = ResolvedTrackWithCover(track: track, coverPath: coverPath);
      tracksWithCover.add(withCover);
      albumTracks.putIfAbsent(track.albumId, () => []).add(withCover);
    }

    final albums = <ResolvedAlbum>[];
    final albumCoverById = <String, String?>{};

    for (final entry in albumTracks.entries) {
      final albumId = entry.key;
      final albumTrackList = entry.value;
      final firstTrack = albumTrackList.first.track;

      String? albumCover;
      for (final item in albumTrackList) {
        if (item.coverPath != null) {
          albumCover = item.coverPath;
          break;
        }
      }

      if (albumCover == null) {
        for (final item in albumTrackList) {
          albumCover = findCoverInDirectory(item.track.parentDir);
          if (albumCover != null) break;
        }
      }

      albumCoverById[albumId] = albumCover;
      final albumArtist = resolveAlbumArtist(
        tracks: albumTrackList
            .map(
              (item) => ResolvedTrackArtistInfo(
                artistId: item.track.artistId,
                artistName: item.track.artistName,
                albumArtistName: item.track.albumArtistName,
              ),
            )
            .toList(),
      );
      albums.add(
        ResolvedAlbum(
          id: albumId,
          title: firstTrack.albumTitle,
          artistId: albumArtist.id,
          year: firstTrack.year,
          coverPath: albumCover,
        ),
      );
    }

    final artistsMap = <String, ResolvedArtist>{};
    for (final track in tracksWithCover) {
      final artistId = track.track.artistId;
      artistsMap.putIfAbsent(
        artistId,
        () => ResolvedArtist(
          id: artistId,
          name: track.track.artistName,
        ),
      );
    }

    for (final album in albums) {
      final albumArtist = resolveAlbumArtist(
        tracks: albumTracks[album.id]!
            .map(
              (item) => ResolvedTrackArtistInfo(
                artistId: item.track.artistId,
                artistName: item.track.artistName,
                albumArtistName: item.track.albumArtistName,
              ),
            )
            .toList(),
      );
      artistsMap.putIfAbsent(
        album.artistId,
        () => ResolvedArtist(
          id: albumArtist.id,
          name: albumArtist.name,
        ),
      );
    }

    for (final album in albums) {
      final artist = artistsMap[album.artistId];
      if (artist == null || artist.coverPath != null) continue;
      if (album.coverPath != null) {
        artistsMap[album.artistId] = ResolvedArtist(
          id: artist.id,
          name: artist.name,
          coverPath: album.coverPath,
        );
      }
    }

    return ResolvedLibrary(
      artists: artistsMap.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
      albums: albums..sort((a, b) => a.title.compareTo(b.title)),
      tracks: tracksWithCover,
    );
  }

  String _extensionForMime(String? mimeType, List<int> bytes) {
    if (mimeType != null) {
      if (mimeType.contains('png')) return 'png';
      if (mimeType.contains('webp')) return 'webp';
      if (mimeType.contains('jpeg') || mimeType.contains('jpg')) return 'jpg';
    }

    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return 'webp';
    }
    return 'jpg';
  }
}
