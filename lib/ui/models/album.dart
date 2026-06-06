class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    this.coverUrl,
    this.year,
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String? coverUrl;
  final int? year;
}
