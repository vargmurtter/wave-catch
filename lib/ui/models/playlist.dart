class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.trackCount,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final int trackCount;
  final bool isSystem;
}
