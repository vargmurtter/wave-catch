import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

class PlayerUiState {
  const PlayerUiState({
    this.currentTrack,
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

  final Track? currentTrack;
  final List<Track> queue;
  final int queueIndex;
  final bool isPlaying;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final double volume;
  final bool isQueueOpen;
  final Duration position;
  final Duration duration;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerUiState copyWith({
    Track? currentTrack,
    List<Track>? queue,
    int? queueIndex,
    bool? isPlaying,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    double? volume,
    bool? isQueueOpen,
    Duration? position,
    Duration? duration,
    bool clearCurrentTrack = false,
  }) {
    return PlayerUiState(
      currentTrack:
          clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
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
