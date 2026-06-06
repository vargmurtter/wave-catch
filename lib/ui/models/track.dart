class Track {
  const Track({
    required this.id,
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
  });

  final String id;
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
}
