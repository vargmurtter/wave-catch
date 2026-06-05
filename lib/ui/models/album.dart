class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
}
