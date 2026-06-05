class Artist {
  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;
}
