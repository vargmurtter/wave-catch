import 'dart:async';
import 'dart:math';

import 'package:media_kit/media_kit.dart' hide Track;

import 'package:music_player/repositories/ytdlp_repository.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/models/playable_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

class PlayerService {
  PlayerService(
    this._libraryService, {
    YtdlpRepository? ytdlpRepository,
  }) : _ytdlpRepository = ytdlpRepository {
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
  final YtdlpRepository? _ytdlpRepository;
  late final Player _player;
  final _stateController = StreamController<PlayerUiState>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  PlayerUiState _state = PlayerUiState.empty;
  List<PlayableItem> _baseQueue = const [];
  bool _isSeeking = false;
  final Map<String, String> _streamUrlByVideoId = {};

  Stream<PlayerUiState> get stateStream => _stateController.stream;
  PlayerUiState get state => _state;

  void _emit(PlayerUiState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  void _patch({
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
    _emit(
      _state.copyWith(
        currentItem: currentItem,
        queue: queue,
        queueIndex: queueIndex,
        isPlaying: isPlaying,
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        volume: volume,
        isQueueOpen: isQueueOpen,
        position: position,
        duration: duration,
        clearCurrentItem: clearCurrentItem,
      ),
    );
  }

  Future<void> playAlbum(String albumId) async {
    final tracks = _libraryService.getTracksForAlbum(albumId);
    if (tracks.isEmpty) return;
    await _setQueue(
      tracks.map(LocalPlayableItem.new).toList(),
      startIndex: 0,
    );
  }

  Future<void> playPlaylist(List<Track> tracks, {Track? startTrack}) async {
    if (tracks.isEmpty) return;
    var startIndex = 0;
    if (startTrack != null) {
      final index = tracks.indexWhere((t) => t.id == startTrack.id);
      if (index >= 0) startIndex = index;
    }
    await _setQueue(
      tracks.map(LocalPlayableItem.new).toList(),
      startIndex: startIndex,
    );
  }

  Future<void> playTrackInAlbum(Track track) async {
    final tracks = _libraryService.getTracksForAlbum(track.albumId);
    if (tracks.isEmpty) return;
    final index = tracks.indexWhere((t) => t.id == track.id);
    await _setQueue(
      tracks.map(LocalPlayableItem.new).toList(),
      startIndex: index >= 0 ? index : 0,
    );
  }

  Future<void> playExploreTrack(ExploreTrack track) {
    return playExploreQueue([track], startIndex: 0);
  }

  Future<void> playExploreQueue(
    List<ExploreTrack> tracks, {
    int startIndex = 0,
  }) async {
    if (tracks.isEmpty) return;
    await _setQueue(
      tracks.map(RemotePlayableItem.new).toList(),
      startIndex: startIndex,
    );
  }

  Future<void> playArtist(String artistId, {Track? startTrack}) async {
    final tracks = _libraryService.getTracksForArtist(artistId);
    if (tracks.isEmpty) return;
    var startIndex = 0;
    if (startTrack != null) {
      final index = tracks.indexWhere((t) => t.id == startTrack.id);
      if (index >= 0) startIndex = index;
    }
    await _setQueue(
      tracks.map(LocalPlayableItem.new).toList(),
      startIndex: startIndex,
    );
  }

  Future<void> playAllShuffled() async {
    final tracks = List<Track>.from(_libraryService.getAllTracks());
    if (tracks.isEmpty) return;
    tracks.shuffle(Random());
    _baseQueue = tracks.map(LocalPlayableItem.new).toList();
    _patch(
      queue: tracks.map(LocalPlayableItem.new).toList(),
      shuffleEnabled: true,
    );
    await _playAtIndex(0, queue: _state.queue);
  }

  Future<void> _setQueue(
    List<PlayableItem> items, {
    required int startIndex,
    bool? shuffleEnabled,
  }) async {
    _baseQueue = List<PlayableItem>.from(items);
    var queue = List<PlayableItem>.from(items);
    final shuffle = shuffleEnabled ?? _state.shuffleEnabled;

    if (shuffle && queue.length > 1) {
      final current = queue[startIndex];
      final rest = List<PlayableItem>.from(queue)..removeAt(startIndex);
      rest.shuffle(Random());
      queue = [current, ...rest];
      startIndex = 0;
    }

    _patch(
      queue: queue,
      shuffleEnabled: shuffle,
    );
    await _playAtIndex(startIndex, queue: queue);
  }

  Future<void> jumpToIndex(int index) async {
    if (index < 0 || index >= _state.queue.length) return;
    await _playAtIndex(index);
  }

  Future<void> _playAtIndex(int index, {List<PlayableItem>? queue}) async {
    final activeQueue = queue ?? _state.queue;
    if (index < 0 || index >= activeQueue.length) return;

    final item = activeQueue[index];
    _patch(
      currentItem: item,
      queue: activeQueue,
      queueIndex: index,
      isPlaying: true,
      position: Duration.zero,
      duration: item.duration,
    );

    try {
      final media = await _resolveMedia(item);
      await _player.open(media);
      await _player.play();
    } on Object {
      if (item is RemotePlayableItem) {
        _streamUrlByVideoId.remove(item.track.videoId);
        _ytdlpRepository?.invalidateStreamCache(item.track.watchUrl);
        try {
          final media = await _resolveMedia(item, forceRefresh: true);
          await _player.open(media);
          await _player.play();
          return;
        } on Object {
          _patch(isPlaying: false);
        }
      } else {
        _patch(isPlaying: false);
      }
    }
  }

  Future<Media> _resolveMedia(
    PlayableItem item, {
    bool forceRefresh = false,
  }) async {
    if (item is LocalPlayableItem) {
      return Media(item.track.filePath);
    }

    if (item is! RemotePlayableItem) {
      throw StateError('Expected remote playable item');
    }

    final exploreTrack = item.track;
    if (!forceRefresh) {
      final cached = _streamUrlByVideoId[exploreTrack.videoId];
      if (cached != null) return Media(cached);
    }

    final ytdlp = _ytdlpRepository;
    if (ytdlp == null) {
      throw StateError('yt-dlp repository is not configured');
    }

    final url = await ytdlp.getStreamUrl(exploreTrack.watchUrl);
    _streamUrlByVideoId[exploreTrack.videoId] = url;
    return Media(url);
  }

  Future<void> togglePlayPause() async {
    if (_state.currentItem == null) return;
    if (_state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> skipNext() async {
    if (_state.queue.isEmpty || _state.currentItem == null) return;

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
    if (_state.currentItem == null) return;

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
      final current = _state.currentItem;
      if (current == null) {
        _patch(
          shuffleEnabled: false,
          queue: List<PlayableItem>.from(_baseQueue),
        );
        return;
      }
      final currentIndexInBase =
          _baseQueue.indexWhere((item) => item.id == current.id);
      final restored = List<PlayableItem>.from(_baseQueue);
      _patch(
        shuffleEnabled: false,
        queue: restored,
        queueIndex: currentIndexInBase,
      );
      return;
    }

    final current = _state.currentItem!;
    final currentIndex = _state.queueIndex;
    final before = _state.queue.sublist(0, currentIndex);
    final after = List<PlayableItem>.from(_state.queue.sublist(currentIndex + 1));
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
    if (_state.currentItem == null) return;
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
    if (_state.currentItem == null) return;
    if (_state.isPlaying != playing) {
      _patch(isPlaying: playing);
    }
  }

  void _onPositionChanged(Duration position) {
    if (_state.currentItem == null || _isSeeking) return;
    _patch(position: position);
  }

  void _onDurationChanged(Duration duration) {
    if (_state.currentItem == null) return;
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

  void updateCurrentTrack(Track track) {
    final queue = List<PlayableItem>.from(_state.queue);
    final queueIndex = _state.queueIndex;
    if (queueIndex >= 0 &&
        queueIndex < queue.length &&
        queue[queueIndex].id == track.id) {
      queue[queueIndex] = LocalPlayableItem(track);
    }
    for (var i = 0; i < queue.length; i++) {
      if (queue[i].id == track.id) {
        queue[i] = LocalPlayableItem(track);
      }
    }

    _patch(
      currentItem: _state.currentItem?.id == track.id
          ? LocalPlayableItem(track)
          : _state.currentItem,
      queue: queue,
    );
  }

  Future<void> replaceCurrentExploreWithLocal(Track track) async {
    final current = _state.currentItem;
    if (current is! RemotePlayableItem) return;

    final queue = List<PlayableItem>.from(_state.queue);
    final index = _state.queueIndex;
    if (index >= 0 && index < queue.length) {
      queue[index] = LocalPlayableItem(track);
    }

    final wasPlaying = _state.isPlaying;
    final position = _state.position;
    _patch(
      currentItem: LocalPlayableItem(track),
      queue: queue,
      duration: track.duration,
    );

    await _player.open(Media(track.filePath));
    if (position > Duration.zero) {
      await _player.seek(position);
    }
    if (wasPlaying) {
      await _player.play();
    }
  }

  ExploreTrack? get currentExploreTrack => _state.currentItem?.exploreTrack;

  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _stateController.close();
    await _player.dispose();
  }
}
