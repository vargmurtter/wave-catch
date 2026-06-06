import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/library_route.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

final selectedNavItemProvider =
    NotifierProvider<SelectedNavItemNotifier, NavItem>(
  SelectedNavItemNotifier.new,
);

class SelectedNavItemNotifier extends Notifier<NavItem> {
  @override
  NavItem build() => NavItem.main;

  void select(NavItem item) {
    state = item;
    ref.read(libraryRouteProvider.notifier).reset();
  }
}

final playerUiStateProvider =
    NotifierProvider<PlayerUiStateNotifier, PlayerUiState>(
  PlayerUiStateNotifier.new,
);

class PlayerUiStateNotifier extends Notifier<PlayerUiState> {
  @override
  PlayerUiState build() => MockData.initialPlayerState;

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleShuffle() {
    state = state.copyWith(shuffleEnabled: !state.shuffleEnabled);
  }

  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void toggleQueue() {
    state = state.copyWith(isQueueOpen: !state.isQueueOpen);
  }

  void closeQueue() {
    state = state.copyWith(isQueueOpen: false);
  }

  void playTrack(Track track) {
    state = state.copyWith(currentTrack: track, isPlaying: true);
  }
}

final homeSectionsProvider = Provider<HomeSections>(
  (ref) => MockData.homeSections,
);

final libraryRouteProvider =
    NotifierProvider<LibraryRouteNotifier, List<LibraryRoute>>(
  LibraryRouteNotifier.new,
);

class LibraryRouteNotifier extends Notifier<List<LibraryRoute>> {
  @override
  List<LibraryRoute> build() => const [LibraryMainRoute()];

  LibraryRoute get current => state.last;

  void reset() {
    state = const [LibraryMainRoute()];
  }

  void goBack() {
    if (state.length <= 1) return;
    state = state.sublist(0, state.length - 1);
  }

  void openArtist(String artistId) {
    state = [...state, ArtistDetailRoute(artistId)];
  }

  void openArtistTracks(String artistId) {
    state = [...state, ArtistTracksRoute(artistId)];
  }

  void openAlbum(String albumId) {
    state = [...state, AlbumDetailRoute(albumId)];
  }
}

final trackInfoPanelProvider =
    NotifierProvider<TrackInfoPanelNotifier, Track?>(
  TrackInfoPanelNotifier.new,
);

class TrackInfoPanelNotifier extends Notifier<Track?> {
  @override
  Track? build() => null;

  void open(Track track) => state = track;

  void close() => state = null;
}
