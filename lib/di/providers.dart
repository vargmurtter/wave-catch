import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/l10n/app_locale.dart';
import 'package:music_player/repositories/app_settings_repository.dart';
import 'package:music_player/repositories/artist_info_cache_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/metadata_file_writer.dart';
import 'package:music_player/repositories/metadata_override_repository.dart';
import 'package:music_player/repositories/musicbrainz_api_repository.dart';
import 'package:music_player/repositories/wikipedia_api_repository.dart';
import 'package:music_player/repositories/ytdlp_auth_settings.dart';
import 'package:music_player/repositories/ytdlp_binary_resolver.dart';
import 'package:music_player/repositories/ytdlp_repository.dart';
import 'package:music_player/repositories/ytm_innertube_repository.dart';
import 'package:music_player/services/artist_info_service.dart';
import 'package:music_player/services/explore_service.dart';
import 'package:music_player/services/library_scanner_service.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/metadata_edit_service.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/player_service.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/services/track_import_service.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/scanner/cover_art_resolver.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/artist_info.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/library_route.dart';
import 'package:music_player/ui/models/library_search_results.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/models/playlist_sort_order.dart';
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
  return LibraryService(
    ref.watch(libraryRepositoryProvider),
    ref.watch(settingsServiceProvider),
    ref.watch(metadataOverrideRepositoryProvider),
  );
});

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService(
    ref.watch(libraryRepositoryProvider),
    ref.watch(libraryServiceProvider),
  );
});

final playerServiceProvider = Provider<PlayerService>((ref) {
  ref.keepAlive();
  final service = PlayerService(
    ref.read(libraryServiceProvider),
    ytdlpRepository: ref.watch(ytdlpRepositoryProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

final ytmInnerTubeRepositoryProvider = Provider<YtmInnerTubeRepository>(
  (ref) => YtmInnerTubeRepository(),
);

final ytdlpBinaryResolverProvider = Provider<YtdlpBinaryResolver>(
  (ref) => YtdlpBinaryResolver(),
);

final ytdlpRepositoryProvider = Provider<YtdlpRepository>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return YtdlpRepository(
    resolver: ref.watch(ytdlpBinaryResolverProvider),
    authSettings: () => settings.ytdlpAuthSettings,
  );
});

final ytdlpAvailableProvider = FutureProvider<bool>((ref) async {
  return ref.watch(ytdlpRepositoryProvider).isAvailable();
});

final ytdlpVersionProvider = FutureProvider<String?>((ref) async {
  return ref.watch(ytdlpRepositoryProvider).getVersion();
});

ImportSourceRepository _importSourceRepository(Ref ref) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  return libraryRepository.importSourceRepository;
}

final exploreServiceProvider = Provider<ExploreService>((ref) {
  return ExploreService(
    ytmRepository: ref.watch(ytmInnerTubeRepositoryProvider),
    libraryService: ref.watch(libraryServiceProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    importSourceRepositoryFactory: () => _importSourceRepository(ref),
  );
});

final trackImportServiceProvider = Provider<TrackImportService>((ref) {
  return TrackImportService(
    settingsService: ref.watch(settingsServiceProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    libraryScannerService: ref.watch(libraryScannerServiceProvider),
    libraryService: ref.watch(libraryServiceProvider),
    ytdlpRepository: ref.watch(ytdlpRepositoryProvider),
    metadataFileWriter: ref.watch(metadataFileWriterProvider),
    importSourceRepositoryFactory: () => _importSourceRepository(ref),
  );
});

final exploreSavedVideoIdsProvider = Provider<Set<String>>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(exploreServiceProvider).savedVideoIds();
});

final exploreRecommendationsProvider =
    FutureProvider<ExploreRecommendations>((ref) async {
  ref.watch(libraryRefreshProvider);
  return ref.watch(exploreServiceProvider).getRecommendations();
});

final exploreSearchProvider =
    FutureProvider.family<List<ExploreTrack>, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];
  return ref.watch(exploreServiceProvider).search(trimmed);
});

class ExploreSuggestionsState {
  const ExploreSuggestionsState({this.textSuggestions = const []});

  final List<String> textSuggestions;
}

final exploreSuggestionsProvider =
    FutureProvider.family<ExploreSuggestionsState, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const ExploreSuggestionsState();
  final result = await ref.watch(exploreServiceProvider).suggestions(trimmed);
  return ExploreSuggestionsState(textSuggestions: result.textSuggestions);
});

class ExploreSaveNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<String?> save(ExploreTrack track) async {
    state = track.videoId;
    try {
      final savedTrack =
          await ref.read(trackImportServiceProvider).saveExploreTrack(track);
      final player = ref.read(playerServiceProvider);
      if (player.currentExploreTrack?.videoId == track.videoId) {
        await player.replaceCurrentExploreWithLocal(savedTrack);
      }
      ref.read(libraryRefreshProvider.notifier).refresh();
      return null;
    } on YtdlpException catch (e) {
      if (e.message.contains('Sign in to confirm your age')) {
        return 'age_restricted';
      }
      return e.message;
    } on Object catch (e) {
      return e.toString();
    } finally {
      state = null;
    }
  }
}

final exploreSaveProvider =
    NotifierProvider<ExploreSaveNotifier, String?>(ExploreSaveNotifier.new);

final exploreSavingVideoIdProvider = Provider<String?>(
  (ref) => ref.watch(exploreSaveProvider),
);

final musicBrainzApiRepositoryProvider = Provider<MusicBrainzApiRepository>(
  (ref) => MusicBrainzApiRepository(),
);

final wikipediaApiRepositoryProvider = Provider<WikipediaApiRepository>(
  (ref) => WikipediaApiRepository(),
);

final artistInfoCacheRepositoryProvider = Provider<ArtistInfoCacheRepository>(
  (ref) => ArtistInfoCacheRepository(),
);

final artistInfoServiceProvider = Provider<ArtistInfoService>((ref) {
  return ArtistInfoService(
    ref.watch(musicBrainzApiRepositoryProvider),
    ref.watch(wikipediaApiRepositoryProvider),
    ref.watch(artistInfoCacheRepositoryProvider),
  );
});

// --- Settings ---

class AppSettingsState {
  const AppSettingsState({
    this.musicLibraryPath,
    this.isConfigured = false,
    this.hasLanguageSelected = false,
    this.language = AppLanguage.en,
    this.albumGroupingStrategy = AlbumGroupingStrategy.byAlbumArtist,
    this.metadataEditMode = MetadataEditMode.override,
    this.ytdlpAuthSettings = const YtdlpAuthSettings(),
  });

  final String? musicLibraryPath;
  final bool isConfigured;
  final bool hasLanguageSelected;
  final AppLanguage language;
  final AlbumGroupingStrategy albumGroupingStrategy;
  final MetadataEditMode metadataEditMode;
  final YtdlpAuthSettings ytdlpAuthSettings;

  Locale get locale => language.locale;
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
      hasLanguageSelected: service.hasLanguageSelected,
      language: service.language ?? AppLanguage.en,
      albumGroupingStrategy: service.albumGroupingStrategy,
      metadataEditMode: service.metadataEditMode,
      ytdlpAuthSettings: service.ytdlpAuthSettings,
    );
  }

  Future<void> reload() async {
    await ref.read(settingsServiceProvider).load();
    _syncFromService();
  }

  Future<String?> pickMusicFolder({required String dialogTitle}) {
    return ref
        .read(settingsServiceProvider)
        .pickMusicFolder(dialogTitle: dialogTitle);
  }

  Future<void> setLanguage(AppLanguage language) async {
    await ref.read(settingsServiceProvider).setLanguage(language);
    _syncFromService();
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

  Future<String?> pickCookiesFile({required String dialogTitle}) {
    return ref
        .read(settingsServiceProvider)
        .pickCookiesFile(dialogTitle: dialogTitle);
  }

  Future<void> setYtdlpAuthSettings(YtdlpAuthSettings settings) async {
    await ref.read(settingsServiceProvider).setYtdlpAuthSettings(settings);
    ref.read(ytdlpRepositoryProvider).invalidateStreamCache();
    _syncFromService();
  }

  void _syncFromService() {
    final service = ref.read(settingsServiceProvider);
    state = AppSettingsState(
      musicLibraryPath: service.musicLibraryPath,
      isConfigured: service.isLibraryConfigured,
      hasLanguageSelected: service.hasLanguageSelected,
      language: service.language ?? AppLanguage.en,
      albumGroupingStrategy: service.albumGroupingStrategy,
      metadataEditMode: service.metadataEditMode,
      ytdlpAuthSettings: service.ytdlpAuthSettings,
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

final playlistsProvider = Provider<List<Playlist>>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(playlistServiceProvider).getPlaylists();
});

final playlistByIdProvider = Provider.family<Playlist?, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(playlistServiceProvider).getPlaylistById(id);
});

final tracksForPlaylistProvider =
    Provider.family<List<Track>, String>((ref, playlistId) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(playlistServiceProvider).getTracksForPlaylist(playlistId);
});

final isTrackFavoriteProvider = Provider.family<bool, String>((ref, trackId) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(playlistServiceProvider).isFavorite(trackId);
});

final trackPlaylistIdsProvider = Provider.family<Set<String>, String>(
  (ref, trackId) {
    ref.watch(libraryRefreshProvider);
    return ref
        .watch(playlistServiceProvider)
        .getPlaylistIdsContainingTrack(trackId);
  },
);

final playlistActionsProvider = Provider<PlaylistActions>((ref) {
  return PlaylistActions(ref);
});

class PlaylistActions {
  PlaylistActions(this._ref);

  final Ref _ref;

  PlaylistService get _service => _ref.read(playlistServiceProvider);

  void _refresh() => _ref.read(libraryRefreshProvider.notifier).refresh();

  Playlist createPlaylist(String name) {
    final playlist = _service.createPlaylist(name);
    _refresh();
    return playlist;
  }

  void deletePlaylist(String id) {
    _service.deletePlaylist(id);
    _refresh();
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    _service.addTrackToPlaylist(playlistId, trackId);
    _refresh();
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    _service.removeTrackFromPlaylist(playlistId, trackId);
    _refresh();
  }

  void setPlaylistSortOrder(String playlistId, PlaylistSortOrder sortOrder) {
    _service.setPlaylistSortOrder(playlistId, sortOrder);
    _refresh();
  }

  bool toggleFavorite(String trackId) {
    final isFavorite = _service.toggleFavorite(trackId);
    _refresh();
    return isFavorite;
  }
}

final homeSectionsProvider = Provider<HomeSections>((ref) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getHomeSections();
});

final artistByIdProvider = Provider.family<Artist?, String>((ref, id) {
  ref.watch(libraryRefreshProvider);
  return ref.watch(libraryServiceProvider).getArtistById(id);
});

final artistInfoProvider = FutureProvider.family<ArtistInfo?, String>(
  (ref, artistId) async {
    final artist = ref.watch(artistByIdProvider(artistId));
    if (artist == null) return null;
    final result = await ref.read(artistInfoServiceProvider).loadArtistInfo(
          artistId: artistId,
          artistName: artist.name,
        );
    if (result?.imagePath != null) {
      ref.read(artistInfoCacheRevisionProvider.notifier).bump();
    }
    return result;
  },
);

final artistInfoCacheRevisionProvider =
    NotifierProvider<ArtistInfoCacheRevisionNotifier, int>(
  ArtistInfoCacheRevisionNotifier.new,
);

class ArtistInfoCacheRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final artistCachedImagePathProvider = FutureProvider.family<String?, String>(
  (ref, artistId) async {
    ref.watch(artistInfoCacheRevisionProvider);
    await ref.read(artistInfoServiceProvider).ensureCacheLoaded();
    return ref.read(artistInfoServiceProvider).cachedImagePath(artistId);
  },
);

final artistDisplayImagePathProvider = FutureProvider.family<String?, String>(
  (ref, artistId) async {
    ref.watch(artistInfoCacheRevisionProvider);
    final artist = ref.watch(artistByIdProvider(artistId));
    if (artist == null) return null;

    final service = ref.read(artistInfoServiceProvider);
    await service.ensureCacheLoaded();
    return service.cachedImagePath(artistId) ?? artist.imageUrl;
  },
);

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

  Future<void> playPlaylist(List<Track> tracks, {Track? startTrack}) =>
      _service.playPlaylist(tracks, startTrack: startTrack);

  Future<void> playTrackInAlbum(Track track) =>
      _service.playTrackInAlbum(track);

  Future<void> playExploreTrack(ExploreTrack track) =>
      _service.playExploreTrack(track);

  Future<void> playExploreQueue(List<ExploreTrack> tracks, {int startIndex = 0}) =>
      _service.playExploreQueue(tracks, startIndex: startIndex);

  Future<void> playArtist(String artistId, {Track? startTrack}) =>
      _service.playArtist(artistId, startTrack: startTrack);

  Future<void> playAllShuffled() => _service.playAllShuffled();

  Future<void> skipNext() => _service.skipNext();

  Future<void> skipPrevious() => _service.skipPrevious();

  Future<void> seek(Duration position) => _service.seek(position);

  Future<void> jumpToIndex(int index) => _service.jumpToIndex(index);
}

final exploreLoadingVideoIdProvider = Provider<String?>((ref) {
  final state = ref.watch(playerUiStateProvider);
  if (!state.isLoading || !state.isExplorePlayback) return null;
  return state.currentItem?.exploreTrack?.videoId;
});

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

  void openPlaylist(String playlistId) {
    state = [...state, PlaylistDetailRoute(playlistId)];
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
    this.errorCode,
    this.errorDetails,
  });

  final bool isSaving;
  final MetadataEditErrorCode? errorCode;
  final String? errorDetails;
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
      // Error message is localized in the UI layer when displayed.
      state = TrackMetadataEditState(
        errorCode: error.code,
        errorDetails: error.details,
      );
      return null;
    } catch (error) {
      state = TrackMetadataEditState(errorDetails: error.toString());
      return null;
    }
  }

  void clearError() {
    state = const TrackMetadataEditState();
  }
}
