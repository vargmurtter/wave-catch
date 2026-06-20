# Architecture

The Wave Catch desktop app is built on a simple, predictable architecture.

## Principles

| Principle | Description |
|-----------|-------------|
| **Repository** | Single entry/exit point for data |
| **Service** | All business logic lives in services |
| **DI** | All dependencies are injected explicitly, with no hidden object creation |
| **KISS** | Simplicity beats "clever" abstractions |

## Layers

```
UI (widgets, screens)
    ↓
Services (business logic)
    ↓
Repositories (data)
    ↓
Sources (filesystem, DB, …)
```

### Repositories

- Responsible only for reading and writing data.
- Hide storage details from the rest of the app.
- Do not contain business rules.

### Services

- Implement use cases: playback, search, playlist management, etc.
- May call multiple repositories and other services.
- Know nothing about widgets or navigation.

### UI

- Displays state and forwards user actions to services.
- Does not access repositories or the filesystem directly.

## Dependency Injection

[Riverpod](https://riverpod.dev/) (`flutter_riverpod`) is used for DI.

- Entry point: `ProviderScope` in `lib/main.dart`.
- Provider registration: `lib/di/providers.dart`.
- Dependencies in services and repositories are passed through constructors.

Wire through DI:

- service → repository;
- service → service;
- UI → service.

Direct dependency creation inside classes (`Repository()` in a service body) is not allowed.

## KISS

- Do not introduce extra interfaces when there is one implementation and no plan to swap it.
- Do not overcomplicate code for "correct" architecture — the three layers above are enough.
- Refactor when a real need appears, not ahead of time.

## Directory structure

```
lib/
  main.dart       # entry point, ProviderScope
  app.dart        # root app widget
  di/
    providers.dart  # Riverpod providers
  repositories/   # LibraryRepository, PlaylistRepository, …
    app_settings_repository.dart
    artist_info_cache_repository.dart
    musicbrainz_api_repository.dart
    wikipedia_api_repository.dart
    lastfm_api_repository.dart
    library_repository.dart
    library_database.dart
    playlist_repository.dart
    import_source_repository.dart
    metadata_override_repository.dart
    metadata_file_writer.dart
    ytm_innertube_repository.dart
    ytdlp_repository.dart
    ytdlp_binary_resolver.dart
    entities/
  services/       # PlayerService, LibraryService, …
    artist_info_service.dart
    settings_service.dart
    library_service.dart
    library_scanner_service.dart
    player_service.dart
    explore_service.dart
    track_import_service.dart
    playlist_service.dart
    metadata/
      metadata_edit_service.dart
    scanner/        # scanner pipeline phases
  l10n/           # localization (ARB, AppLocalizations)
  ui/
    screens/      # screens
    widgets/      # reusable widgets
docs/             # documentation (this file and others)
```

## Data modules (implemented)

| Module | Layer | Purpose |
|--------|-------|---------|
| `AppSettingsRepository` | Repository | music folder path, UI language (Application Support) |
| `LibraryRepository` | Repository | CRUD for index in `.wave_catcher/library.db` |
| `SettingsService` | Service | folder selection, configuration checks |
| `LibraryScannerService` | Service | scan orchestration |
| `LibraryService` | Service | library reads for UI, global search |
| `PlaylistRepository` | Repository | CRUD for playlists and membership in `library.db` |
| `PlaylistService` | Service | user playlists, favorites, track membership |
| `PlayerService` | Service | playback, queue, repeat/shuffle |
| `MetadataOverrideRepository` | Repository | metadata override config in `.wave_catcher/` |
| `MetadataFileWriter` | Repository | write tags to audio files via `metadata_god` |
| `MetadataEditService` | Service | track metadata editing |
| `MusicBrainzApiRepository` | Repository | artist lookup, Wikipedia/Wikidata links |
| `WikipediaApiRepository` | Repository | description and image from Wikipedia/Wikidata |
| `ArtistInfoCacheRepository` | Repository | on-disk artist data cache |
| `ArtistInfoService` | Service | fetch and cache artist information |
| `LastFmApiRepository` | Repository | *(inactive)* HTTP requests to Last.fm API |
| `YtmInnerTubeRepository` | Repository | YouTube Music: search, suggestions, Up Next, artist top tracks (InnerTube) |
| `YtdlpRepository` | Repository | stream URL and audio download via yt-dlp |
| `YtdlpBinaryResolver` | Repository | binary lookup: bundle (in-place) → Linux fallback → PATH |
| `ImportSourceRepository` | Repository | `video_id` ↔ local file mapping (`import_sources`) |
| `ExploreService` | Service | search and recommendations in Explore |
| `TrackImportService` | Service | save a track from Explore to `{musicRoot}/Imports/` |

Library scanning details: [features/library-scanning.md](features/library-scanning.md).  
Search details: [features/library-search.md](features/library-search.md).  
Explore: [features/explore.md](features/explore.md).  
Player details: [features/player.md](features/player.md).  
Playlists: [features/playlists.md](features/playlists.md).  
Settings overview: [features/settings.md](features/settings.md).  
Metadata editing: [features/metadata-editing.md](features/metadata-editing.md).  
Artist information: [features/artist-info.md](features/artist-info.md).  
Localization: [features/localization.md](features/localization.md).

## Documentation

Any architecture change, new module, or feature must be accompanied by updates to files in `docs/`.
