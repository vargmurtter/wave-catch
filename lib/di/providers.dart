import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/repeat_mode.dart';

final selectedNavItemProvider =
    NotifierProvider<SelectedNavItemNotifier, NavItem>(
  SelectedNavItemNotifier.new,
);

class SelectedNavItemNotifier extends Notifier<NavItem> {
  @override
  NavItem build() => NavItem.main;

  void select(NavItem item) => state = item;
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
}

final homeSectionsProvider = Provider<HomeSections>(
  (ref) => MockData.homeSections,
);
