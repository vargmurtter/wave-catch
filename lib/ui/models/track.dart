class Track {
  const Track({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.albumId,
    this.albumArtUrl,
    this.album,
    this.year,
    this.duration = Duration.zero,
    this.trackNumber,
    this.genre,
    this.format,
    this.bitrate,
    this.featuredArtists = const [],
    this.albumArtist,
    this.discNumber,
  });

  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String artistId;
  final String albumId;
  final String? albumArtUrl;
  final String? album;
  final int? year;
  final Duration duration;
  final int? trackNumber;
  final String? genre;
  final String? format;
  final int? bitrate;
  final List<String> featuredArtists;
  final String? albumArtist;
  final int? discNumber;

  Track copyWith({
    String? title,
    String? artist,
    String? artistId,
    String? albumId,
    String? albumArtUrl,
    String? album,
    int? year,
    Duration? duration,
    int? trackNumber,
    String? genre,
    String? format,
    int? bitrate,
    List<String>? featuredArtists,
    String? albumArtist,
    int? discNumber,
  }) {
    return Track(
      id: id,
      filePath: filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      albumId: albumId ?? this.albumId,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      album: album ?? this.album,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
      genre: genre ?? this.genre,
      format: format ?? this.format,
      bitrate: bitrate ?? this.bitrate,
      featuredArtists: featuredArtists ?? this.featuredArtists,
      albumArtist: albumArtist ?? this.albumArtist,
      discNumber: discNumber ?? this.discNumber,
    );
  }
}
