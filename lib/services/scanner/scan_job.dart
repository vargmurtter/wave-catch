import 'package:music_player/services/scanner/album_grouping_strategy.dart';

enum ScanMode {
  initial,
  rescan,
}

class ScanProgress {
  const ScanProgress({
    required this.processed,
    required this.total,
    this.currentPath,
  });

  final int processed;
  final int total;
  final String? currentPath;

  double get fraction => total == 0 ? 0 : processed / total;
}

class ScanResult {
  const ScanResult({
    required this.trackCount,
    required this.artistCount,
    required this.albumCount,
    this.errors = const [],
  });

  final int trackCount;
  final int artistCount;
  final int albumCount;
  final List<String> errors;
}

typedef ScanProgressCallback = void Function(ScanProgress progress);

class ScanJob {
  const ScanJob({
    required this.musicRoot,
    required this.mode,
    this.albumGroupingStrategy = AlbumGroupingStrategy.byAlbumArtist,
  });

  final String musicRoot;
  final ScanMode mode;
  final AlbumGroupingStrategy albumGroupingStrategy;
}
