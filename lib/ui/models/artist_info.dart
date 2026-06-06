class ArtistInfo {
  const ArtistInfo({
    this.description,
    this.imagePath,
  });

  final String? description;
  final String? imagePath;

  bool get hasContent =>
      (description != null && description!.isNotEmpty) ||
      (imagePath != null && imagePath!.isNotEmpty);
}
