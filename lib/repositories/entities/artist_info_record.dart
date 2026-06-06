class ArtistInfoRecord {
  const ArtistInfoRecord({
    required this.artistId,
    this.description,
    this.imagePath,
    required this.cachedAt,
  });

  final String artistId;
  final String? description;
  final String? imagePath;
  final DateTime cachedAt;

  bool get hasContent =>
      (description != null && description!.isNotEmpty) ||
      (imagePath != null && imagePath!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      'artistId': artistId,
      if (description != null) 'description': description,
      if (imagePath != null) 'imagePath': imagePath,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory ArtistInfoRecord.fromJson(Map<String, dynamic> json) {
    return ArtistInfoRecord(
      artistId: json['artistId'] as String,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }
}
