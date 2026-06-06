import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/scanner/id_generator.dart';
import 'package:music_player/services/scanner/scan_rules.dart';

final _featuringPattern = RegExp(
  r'\s+(feat\.?|ft\.?|featuring)\s+.*$',
  caseSensitive: false,
);

String stripFeaturing(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.replaceFirst(_featuringPattern, '').trim();
}

String resolveGroupingArtist({
  required String? albumArtist,
  required String trackArtist,
}) {
  final album = albumArtist?.trim();
  if (album != null && album.isNotEmpty) return album;

  final stripped = stripFeaturing(trackArtist);
  if (stripped.isNotEmpty) return stripped;

  return trackArtist;
}

String computeAlbumId({
  required AlbumGroupingStrategy strategy,
  required String albumTitle,
  required String parentDir,
  required String? albumArtist,
  required String trackArtist,
  int? year,
}) {
  switch (strategy) {
    case AlbumGroupingStrategy.byAlbumArtist:
      final groupingArtist = resolveGroupingArtist(
        albumArtist: albumArtist,
        trackArtist: trackArtist,
      );
      return albumIdFor(groupingArtist, albumTitle);

    case AlbumGroupingStrategy.byFolder:
      return hashId(
        '${normalizeKey(parentDir)}|${normalizeKey(albumTitle)}',
      );

    case AlbumGroupingStrategy.byAlbumTitle:
      final normalizedTitle = normalizeKey(albumTitle);
      if (year != null) {
        return hashId('$normalizedTitle|$year');
      }
      return hashId(normalizedTitle);
  }
}

AlbumArtistResolution resolveAlbumArtist({
  required List<ResolvedTrackArtistInfo> tracks,
}) {
  final albumArtistCounts = <String, int>{};
  for (final track in tracks) {
    final name = track.albumArtistName?.trim();
    if (name == null || name.isEmpty) continue;
    albumArtistCounts[name] = (albumArtistCounts[name] ?? 0) + 1;
  }

  if (albumArtistCounts.isNotEmpty) {
    final best = albumArtistCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    return AlbumArtistResolution(
      id: artistIdFor(best.key),
      name: best.key,
    );
  }

  final trackArtistIds = tracks.map((track) => track.artistId).toSet();
  if (trackArtistIds.length == 1) {
    final track = tracks.first;
    return AlbumArtistResolution(
      id: track.artistId,
      name: track.artistName,
    );
  }

  return AlbumArtistResolution(
    id: artistIdFor(kVariousArtists),
    name: kVariousArtists,
  );
}

class ResolvedTrackArtistInfo {
  const ResolvedTrackArtistInfo({
    required this.artistId,
    required this.artistName,
    this.albumArtistName,
  });

  final String artistId;
  final String artistName;
  final String? albumArtistName;
}

class AlbumArtistResolution {
  const AlbumArtistResolution({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
