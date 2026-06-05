import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

class PlayerUiState {
  const PlayerUiState({
    required this.currentTrack,
    required this.queue,
    this.isPlaying = false,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 0.7,
    this.isQueueOpen = false,
    this.progress = 0.35,
  });

  final Track currentTrack;
  final List<Track> queue;
  final bool isPlaying;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final double volume;
  final bool isQueueOpen;
  final double progress;

  PlayerUiState copyWith({
    Track? currentTrack,
    List<Track>? queue,
    bool? isPlaying,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    double? volume,
    bool? isQueueOpen,
    double? progress,
  }) {
    return PlayerUiState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isQueueOpen: isQueueOpen ?? this.isQueueOpen,
      progress: progress ?? this.progress,
    );
  }
}
