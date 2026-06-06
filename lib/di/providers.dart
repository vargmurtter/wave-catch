import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/repositories/app_settings_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/metadata_file_writer.dart';
import 'package:music_player/repositories/metadata_override_repository.dart';
import 'package:music_player/services/library_scanner_service.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/metadata_edit_service.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/player_service.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/scanner/cover_art_resolver.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/library_route.dart';
import 'package:music_player/ui/models/library_search_results.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
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

final metadataOverrideRepositoryProvider =
    Provider<MetadataOverrideRepository>(
  (ref) => MetadataOverrideRepository(),
);

final metadataFileWriterProvider = Provider<MetadataFileWriter>(
  (ref) => MetadataFileWriter(),
);

final coverArtResolverProvider = Provider<CoverArtResolver>(
  (ref) => CoverArtResolver(),
);

final metadataEditServiceProvider = Provider<MetadataEditService>((ref) {
  return MetadataEditService(
    settingsService: ref.watch(settingsServiceProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    overrideRepository: ref.watch(metadataOverrideRepositoryProvider),
    fileWriter: ref.watch(metadataFileWriterProvider),
    coverArtResolver: ref.watch(coverArtResolverProvider),
  );
});

final libraryScannerServiceProvider = Provider<LibraryScannerService>((ref) {
  return LibraryScannerService(
    settingsService: ref.watch(settingsServiceProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    overrideRepository: ref.watch(metadataOverrideRepositoryProvider),
    coverArtResolver: ref.watch(coverArtResolverProvider),
  );
});

final libraryServiceProvider = Provider<LibraryService>((ref) {
  ref.watch(libraryRefreshProvider);
  return LibraryService(
    ref.watch(libraryRepositoryProvider),
    ref.watch(settingsServiceProvider),
    ref.watch(metadataOverrideRepositoryProvider),
  );
});

final playerServiceProvider = Provider<PlayerService>((ref) {
  final service = PlayerService(ref.watch(libraryServiceProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

// --- Settings ---

class AppSettingsState {
  const AppSettingsState({
    this.musicLibraryPath,
    this.isConfigured = false,
    this.albumGroupingStrategy = AlbumGroupingStrategy.byAlbumArtist,
    this.metadataEditMode = MetadataEditMode.override,
  });

  final String? musicLibraryPath;
  final bool isConfigured;
  final AlbumGroupingStrategy albumGroupingStrategy;
  final MetadataEditMode metadataEditMode;
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
      albumGroupingStrategy: service.albumGroupingStrategy,
      metadataEditMode: service.metadataEditMode,
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

  Future<void> setAlbumGroupingStrategy(AlbumGroupingStrategy strategy) async {
    await ref.read(settingsServiceProvider).setAlbumGroupingStrategy(strategy);
    _syncFromService();
  }

  Future<void> setMetadataEditMode(MetadataEditMode mode) async {
    await ref.read(settingsServiceProvider).setMetadataEditMode(mode);
    ref.read(libraryServiceProvider).refreshOverrides();
    _syncFromService();
  }

  void _syncFromService() {
    final service = ref.read(settingsServiceProvider);
    state = AppSettingsState(
      musicLibraryPath: service.musicLibraryPath,
      isConfigured: service.isLibraryConfigured,
      albumGroupingStrategy: service.albumGroupingStrategy,
      metadataEditMode: service.metadataEditMode,
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
      final strategy = ref.read(settingsServiceProvider).albumGroupingStrategy;
      final result = await ref.read(libraryScannerServiceProvider).scan(
            ScanJob(
              musicRoot: musicRoot,
              mode: mode,
              albumGroupingStrategy: strategy,
            ),
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
  StreamSubscription<PlayerUiState>? _subscription;

  @override
  PlayerUiState build() {
    final service = ref.watch(playerServiceProvider);
    _subscription?.cancel();
    _subscription = service.stateStream.listen((next) {
      state = next;
    });
    ref.onDispose(() => _subscription?.cancel());
    return service.state;
  }

  PlayerService get _service => ref.read(playerServiceProvider);

  void togglePlayPause() => _service.togglePlayPause();

  void toggleShuffle() => _service.toggleShuffle();

  void cycleRepeatMode() => _service.cycleRepeatMode();

  void setVolume(double volume) => _service.setVolume(volume);

  void toggleQueue() => _service.toggleQueue();

  void closeQueue() => _service.closeQueue();

  Future<void> playAlbum(String albumId) => _service.playAlbum(albumId);

  Future<void> playTrackInAlbum(Track track) =>
      _service.playTrackInAlbum(track);

  Future<void> playArtist(String artistId, {Track? startTrack}) =>
      _service.playArtist(artistId, startTrack: startTrack);

  Future<void> playAllShuffled() => _service.playAllShuffled();

  Future<void> skipNext() => _service.skipNext();

  Future<void> skipPrevious() => _service.skipPrevious();

  Future<void> seek(Duration position) => _service.seek(position);

  Future<void> jumpToIndex(int index) => _service.jumpToIndex(index);
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

  void update(Track track) => state = track;

  void close() => state = null;
}

class TrackMetadataEditState {
  const TrackMetadataEditState({
    this.isSaving = false,
    this.errorMessage,
  });

  final bool isSaving;
  final String? errorMessage;
}

final trackMetadataEditProvider =
    NotifierProvider<TrackMetadataEditNotifier, TrackMetadataEditState>(
  TrackMetadataEditNotifier.new,
);

class TrackMetadataEditNotifier extends Notifier<TrackMetadataEditState> {
  @override
  TrackMetadataEditState build() => const TrackMetadataEditState();

  Future<Track?> save({
    required String trackId,
    required TrackMetadataEdit changes,
  }) async {
    state = const TrackMetadataEditState(isSaving: true);

    try {
      final result = await ref
          .read(metadataEditServiceProvider)
          .updateTrackMetadata(trackId: trackId, changes: changes);

      ref.read(libraryServiceProvider).refreshOverrides();
      ref.read(libraryRefreshProvider.notifier).refresh();

      final updatedTrack = result.track;
      final panelTrack = ref.read(trackInfoPanelProvider);
      if (panelTrack?.id == trackId) {
        ref.read(trackInfoPanelProvider.notifier).update(updatedTrack);
      }

      final playerState = ref.read(playerUiStateProvider);
      if (playerState.currentTrack?.id == trackId) {
        ref.read(playerServiceProvider).updateCurrentTrack(updatedTrack);
      }

      state = const TrackMetadataEditState();
      return updatedTrack;
    } on MetadataEditException catch (error) {
      state = TrackMetadataEditState(errorMessage: error.message);
      return null;
    } catch (error) {
      state = TrackMetadataEditState(errorMessage: error.toString());
      return null;
    }
  }

  void clearError() {
    state = const TrackMetadataEditState();
  }
}
