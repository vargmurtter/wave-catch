import 'package:music_player/ui/models/playlist_sort_order.dart';

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.trackCount,
    this.isSystem = false,
    this.sortOrder = PlaylistSortOrder.asc,
  });

  final String id;
  final String name;
  final int trackCount;
  final bool isSystem;
  final PlaylistSortOrder sortOrder;
}
