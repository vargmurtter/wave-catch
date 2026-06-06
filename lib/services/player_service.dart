import 'dart:async';
import 'dart:math';

import 'package:media_kit/media_kit.dart' hide Track;

import 'package:music_player/services/library_service.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

class PlayerService {
  PlayerService(this._libraryService) {
    _player = Player();
    _player.setVolume(_state.volume * 100);
    _subscriptions.add(_player.stream.playing.listen(_onPlayingChanged));
    _subscriptions.add(_player.stream.position.listen(_onPositionChanged));
    _subscriptions.add(_player.stream.duration.listen(_onDurationChanged));
    _subscriptions.add(
      _player.stream.completed.listen((completed) {
        if (completed) _onTrackCompleted();
      }),
    );
  }

  final LibraryService _libraryService;
  late final Player _player;
  final _stateController = StreamController<PlayerUiState>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  PlayerUiState _state = PlayerUiState.empty;
  List<Track> _baseQueue = const [];
  bool _isSeeking = false;

  Stream<PlayerUiState> get stateStream => _stateController.stream;
  PlayerUiState get state => _state;

  void _emit(PlayerUiState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  void _patch({
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
    _emit(
      _state.copyWith(
        currentTrack: currentTrack,
        queue: queue,
        queueIndex: queueIndex,
        isPlaying: isPlaying,
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        volume: volume,
        isQueueOpen: isQueueOpen,
        position: position,
        duration: duration,
        clearCurrentTrack: clearCurrentTrack,
      ),
    );
  }

  Future<void> playAlbum(String albumId) async {
    final tracks = _libraryService.getTracksForAlbum(albumId);
    if (tracks.isEmpty) return;
    await _setQueue(tracks, startIndex: 0);
  }

  Future<void> playTrackInAlbum(Track track) async {
    final tracks = _libraryService.getTracksForAlbum(track.albumId);
    if (tracks.isEmpty) return;
    final index = tracks.indexWhere((t) => t.id == track.id);
    await _setQueue(tracks, startIndex: index >= 0 ? index : 0);
  }

  Future<void> playArtist(String artistId, {Track? startTrack}) async {
    final tracks = _libraryService.getTracksForArtist(artistId);
    if (tracks.isEmpty) return;
    var startIndex = 0;
    if (startTrack != null) {
      final index = tracks.indexWhere((t) => t.id == startTrack.id);
      if (index >= 0) startIndex = index;
    }
    await _setQueue(tracks, startIndex: startIndex);
  }

  Future<void> playAllShuffled() async {
    final tracks = List<Track>.from(_libraryService.getAllTracks());
    if (tracks.isEmpty) return;
    tracks.shuffle(Random());
    _baseQueue = List<Track>.from(_libraryService.getAllTracks());
    _patch(
      queue: tracks,
      shuffleEnabled: true,
    );
    await _playAtIndex(0, tracks: tracks);
  }

  Future<void> _setQueue(
    List<Track> tracks, {
    required int startIndex,
    bool? shuffleEnabled,
  }) async {
    _baseQueue = List<Track>.from(tracks);
    var queue = List<Track>.from(tracks);
    final shuffle = shuffleEnabled ?? _state.shuffleEnabled;

    if (shuffle && queue.length > 1) {
      final current = queue[startIndex];
      final rest = List<Track>.from(queue)..removeAt(startIndex);
      rest.shuffle(Random());
      queue = [current, ...rest];
      startIndex = 0;
    }

    _patch(
      queue: queue,
      shuffleEnabled: shuffle,
    );
    await _playAtIndex(startIndex, tracks: queue);
  }

  Future<void> jumpToIndex(int index) async {
    if (index < 0 || index >= _state.queue.length) return;
    await _playAtIndex(index);
  }

  Future<void> _playAtIndex(int index, {List<Track>? tracks}) async {
    final queue = tracks ?? _state.queue;
    if (index < 0 || index >= queue.length) return;

    final track = queue[index];
    _patch(
      currentTrack: track,
      queue: queue,
      queueIndex: index,
      isPlaying: true,
      position: Duration.zero,
      duration: track.duration,
    );

    await _player.open(Media(track.filePath));
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_state.currentTrack == null) return;
    if (_state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> skipNext() async {
    if (_state.queue.isEmpty || _state.currentTrack == null) return;

    if (_state.repeatMode == RepeatMode.one) {
      await seek(Duration.zero);
      await _player.play();
      return;
    }

    final isLast = _state.queueIndex >= _state.queue.length - 1;
    if (isLast) {
      if (_state.repeatMode == RepeatMode.all) {
        await _playAtIndex(0);
      } else {
        await _player.pause();
        _patch(isPlaying: false);
      }
      return;
    }

    await _playAtIndex(_state.queueIndex + 1);
  }

  Future<void> skipPrevious() async {
    if (_state.currentTrack == null) return;

    if (_state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_state.queue.isEmpty) return;

    if (_state.queueIndex > 0) {
      await _playAtIndex(_state.queueIndex - 1);
      return;
    }

    if (_state.repeatMode == RepeatMode.all && _state.queue.length > 1) {
      await _playAtIndex(_state.queue.length - 1);
    } else {
      await seek(Duration.zero);
    }
  }

  void toggleShuffle() {
    if (_state.queue.length <= 1) {
      _patch(shuffleEnabled: !_state.shuffleEnabled);
      return;
    }

    final enabled = !_state.shuffleEnabled;
    if (!enabled) {
      final current = _state.currentTrack;
      if (current == null) {
        _patch(shuffleEnabled: false, queue: List<Track>.from(_baseQueue));
        return;
      }
      final currentIndexInBase =
          _baseQueue.indexWhere((t) => t.id == current.id);
      final restored = List<Track>.from(_baseQueue);
      _patch(shuffleEnabled: false, queue: restored, queueIndex: currentIndexInBase);
      return;
    }

    final current = _state.currentTrack!;
    final currentIndex = _state.queueIndex;
    final before = _state.queue.sublist(0, currentIndex);
    final after = List<Track>.from(_state.queue.sublist(currentIndex + 1));
    after.shuffle(Random());
    final newQueue = [...before, current, ...after];
    _patch(
      shuffleEnabled: true,
      queue: newQueue,
      queueIndex: before.length,
    );
  }

  void cycleRepeatMode() {
    final next = switch (_state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    _patch(repeatMode: next);
  }

  Future<void> seek(Duration position) async {
    if (_state.currentTrack == null) return;
    _isSeeking = true;
    _patch(position: position);
    await _player.seek(position);
    _isSeeking = false;
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _patch(volume: clamped);
    await _player.setVolume(clamped * 100);
  }

  void toggleQueue() {
    _patch(isQueueOpen: !_state.isQueueOpen);
  }

  void closeQueue() {
    _patch(isQueueOpen: false);
  }

  void _onPlayingChanged(bool playing) {
    if (_state.currentTrack == null) return;
    if (_state.isPlaying != playing) {
      _patch(isPlaying: playing);
    }
  }

  void _onPositionChanged(Duration position) {
    if (_state.currentTrack == null || _isSeeking) return;
    _patch(position: position);
  }

  void _onDurationChanged(Duration duration) {
    if (_state.currentTrack == null) return;
    if (duration > Duration.zero) {
      _patch(duration: duration);
    }
  }

  Future<void> _onTrackCompleted() async {
    if (_state.repeatMode == RepeatMode.one) {
      await seek(Duration.zero);
      await _player.play();
      return;
    }
    await skipNext();
  }

  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _stateController.close();
    await _player.dispose();
  }
}
