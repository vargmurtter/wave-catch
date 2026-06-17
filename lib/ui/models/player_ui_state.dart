import 'package:music_player/ui/models/playable_item.dart';
import 'package:music_player/ui/models/playback_mode.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

class PlayerUiState {
  const PlayerUiState({
    this.currentItem,
    this.queue = const [],
    this.queueIndex = 0,
    this.isPlaying = false,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 0.7,
    this.isQueueOpen = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  static const empty = PlayerUiState();

  final PlayableItem? currentItem;
  final List<PlayableItem> queue;
  final int queueIndex;
  final bool isPlaying;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final double volume;
  final bool isQueueOpen;
  final Duration position;
  final Duration duration;

  PlaybackMode get playbackMode =>
      currentItem?.playbackMode ?? PlaybackMode.library;

  bool get isExplorePlayback => playbackMode == PlaybackMode.explore;

  Track? get currentTrack => currentItem?.libraryTrack;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerUiState copyWith({
    PlayableItem? currentItem,
    List<PlayableItem>? queue,
    int? queueIndex,
    bool? isPlaying,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    double? volume,
    bool? isQueueOpen,
    Duration? position,
    Duration? duration,
    bool clearCurrentItem = false,
  }) {
    return PlayerUiState(
      currentItem:
          clearCurrentItem ? null : (currentItem ?? this.currentItem),
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isQueueOpen: isQueueOpen ?? this.isQueueOpen,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}
