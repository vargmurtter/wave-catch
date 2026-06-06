class ArtistRecord {
  const ArtistRecord({
    required this.id,
    required this.name,
    this.coverPath,
  });

  final String id;
  final String name;
  final String? coverPath;
}

class AlbumRecord {
  const AlbumRecord({
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

class TrackRecord {
  const TrackRecord({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artistId,
    required this.albumId,
    required this.durationMs,
    required this.indexedAtMs,
    this.trackNumber,
    this.genre,
    this.format,
    this.bitrate,
    this.coverPath,
    this.fileModifiedMs,
    this.featuredArtists = const [],
    this.albumArtist,
    this.discNumber,
  });

  final String id;
  final String filePath;
  final String title;
  final String artistId;
  final String albumId;
  final int durationMs;
  final int indexedAtMs;
  final int? trackNumber;
  final String? genre;
  final String? format;
  final int? bitrate;
  final String? coverPath;
  final int? fileModifiedMs;
  final List<String> featuredArtists;
  final String? albumArtist;
  final int? discNumber;
}
