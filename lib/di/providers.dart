import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/repositories/app_settings_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/services/library_scanner_service.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/library_route.dart';
import 'package:music_player/ui/models/library_search_results.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';

// --- Repositories & Services ---

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) => AppSettingsRepository(),
);

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(appSettingsRepositoryProvider));
});

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(),
);

final libraryScannerServiceProvider = Provider<LibraryScannerService>((ref) {
  return LibraryScannerService(
    settingsService: ref.watch(settingsServiceProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
  );
});

final libraryServiceProvider = Provider<LibraryService>((ref) {
  ref.watch(libraryRefreshProvider);
  return LibraryService(
    ref.watch(libraryRepositoryProvider),
    ref.watch(settingsServiceProvider),
  );
});

// --- Settings ---

class AppSettingsState {
  const AppSettingsState({
    this.musicLibraryPath,
    this.isConfigured = false,
  });

  final String? musicLibraryPath;
  final bool isConfigured;
}

final appSettingsStateProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    final service = ref.read(settingsServiceProvider);
    return AppSettingsState(
      musicLibraryPath: service.musicLibraryPath,
      isConfigured: service.isLibraryConfigured,
    );
  }

  Future<void> reload() async {
    await ref.read(settingsServiceProvider).load();
    _syncFromService();
  }

  Future<String?> pickMusicFolder() {
    return ref.read(settingsServiceProvider).pickMusicFolder();
  }

  Future<void> setMusicLibraryPath(String path) async {
    await ref.read(settingsServiceProvider).setMusicLibraryPath(path);
    _syncFromService();
  }

  void _syncFromService() {
    final service = ref.read(settingsServiceProvider);
    state = AppSettingsState(
      musicLibraryPath: service.musicLibraryPath,
      isConfigured: service.isLibraryConfigured,
    );
  }
}

// --- Library scan ---

enum LibraryScanStatus { idle, scanning, completed, error }

class LibraryScanState {
  const LibraryScanState({
    this.status = LibraryScanStatus.idle,
    this.progress,
    this.result,
    this.errorMessage,
  });

  final LibraryScanStatus status;
  final ScanProgress? progress;
  final ScanResult? result;
  final String? errorMessage;
}

final libraryScanStateProvider =
    NotifierProvider<LibraryScanNotifier, LibraryScanState>(
  LibraryScanNotifier.new,
);

class LibraryScanNotifier extends Notifier<LibraryScanState> {
  @override
  LibraryScanState build() => const LibraryScanState();

  Future<ScanResult?> scanLibrary({
    required String musicRoot,
    ScanMode mode = ScanMode.initial,
  }) async {
    state = const LibraryScanState(status: LibraryScanStatus.scanning);

    try {
      final result = await ref.read(libraryScannerServiceProvider).scan(
            ScanJob(musicRoot: musicRoot, mode: mode),
            onProgress: (progress) {
              state = LibraryScanState(
                status: LibraryScanStatus.scanning,
                progress: progress,
              );
            },
          );

      ref.read(libraryRefreshProvider.notifier).refresh();
      await ref.read(appSettingsStateProvider.notifier).reload();

      state = LibraryScanState(
        status: LibraryScanStatus.completed,
        result: result,
      );
      return result;
    } catch (error) {
      state = LibraryScanState(
        status: LibraryScanStatus.error,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const LibraryScanState();
  }
}

final libraryRefreshProvider =
    NotifierProvider<LibraryRefreshNotifier, int>(LibraryRefreshNotifier.new);

class LibraryRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

// --- Library data ---

final artistsProvider = Provider<List<Artist>>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getArtists();
});

final albumsProvider = Provider<List<Album>>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getAlbums();
});

final homeSectionsProvider = Provider<HomeSections>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getHomeSections();
});

final artistByIdProvider = Provider.family<Artist?, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getArtistById(id);
});

final albumByIdProvider = Provider.family<Album?, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getAlbumById(id);
});

final tracksForAlbumProvider = Provider.family<List<Track>, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getTracksForAlbum(id);
});

final tracksForArtistProvider =
    Provider.family<List<Track>, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getTracksForArtist(id);
});

final albumsForArtistProvider = Provider.family<List<Album>, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getAlbumsForArtist(id);
});

final otherAlbumsByArtistProvider =
    Provider.family<List<Album>, ({String artistId, String excludeAlbumId})>(
  (ref, params) {
    ref.watch(libraryRefreshProvider);
    return ref.watch(libraryServiceProvider).getOtherAlbumsByArtist(
          params.artistId,
          excludeAlbumId: params.excludeAlbumId,
        );
  },
);

// --- Search ---

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return '';
  }

  void set(String query) {
    state = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      ref.read(debouncedSearchQueryProvider.notifier).set(query);
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(debouncedSearchQueryProvider.notifier).set('');
  }
}

final debouncedSearchQueryProvider =
    NotifierProvider<DebouncedSearchQueryNotifier, String>(
  DebouncedSearchQueryNotifier.new,
);

class DebouncedSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final librarySearchResultsProvider = Provider<LibrarySearchResults>((ref) {
  ref.watch(libraryRefreshProvider);
  final query = ref.watch(debouncedSearchQueryProvider);
  if (query.trim().isEmpty) return LibrarySearchResults.empty;
  return ref.watch(libraryServiceProvider).search(query);
});

// --- UI state ---

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
