class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtUrl,
    this.album,
  });

  final String id;
  final String title;
  final String artist;
  final String? albumArtUrl;
  final String? album;
}
