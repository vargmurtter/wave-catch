# Music library scanning

Recursive scan of the music folder, metadata and cover extraction, index stored in SQLite.

## Storage

| Data | Location |
|------|----------|
| Music folder path | `{ApplicationSupport}/.wave_catcher/app_config.json` |
| Album grouping strategy | `{ApplicationSupport}/.wave_catcher/app_config.json` |
| Library index | `{musicRoot}/.wave_catcher/library.db` |
| YouTube → file mapping | `import_sources` table in `library.db` (schema v3) |
| Explore imports | `{musicRoot}/Imports/{Artist}/{Title}.mp3` |
| Override config | `{musicRoot}/.wave_catcher/metadata_overrides.json` |
| Embedded covers | `{musicRoot}/.wave_catcher/covers/` |
| Playlists | `playlists`, `playlist_tracks` tables in `library.db` (schema v4+) — see [playlists.md](playlists.md) |

## Database schema versions

Migrations run in `library_database.dart` when opening `library.db`:

| Version | Change |
|---------|--------|
| v3 | `import_sources` (Explore video → file) |
| v4 | `playlists`, `playlist_tracks`; Favorites system playlist |
| v5 | Saved system playlist; backfill from `import_sources` |
| v6 | `added_at_sort_asc` on playlists (sort by date added) |

Playlists: [playlists.md](playlists.md).

## First launch and settings

- On first launch, if no path is saved, `OnboardingScreen` is shown with folder selection via the system dialog (`file_picker`).
- **Settings** in the sidebar: current path, change folder, rescan, **album grouping**. Full index: [settings.md](settings.md).

## Album grouping

Strategy is chosen in **Settings → Album grouping** and saved in `app_config.json` (`albumGroupingStrategy`). Changing strategy requires a **rescan** — album composition in `library.db` is recalculated from scratch.

| Strategy | `albumId` key | When to use |
|----------|---------------|-------------|
| **By tags (Album Artist)** — default | `hash(groupingArtist \| albumTitle)` | Most libraries with tags. `groupingArtist` = `albumArtist` → artist without `feat.` → track artist |
| **By folder on disk** | `hash(parentDir \| albumTitle)` | Music organized as `Artist/Album/` folders |
| **By album title** | `hash(albumTitle)` or `hash(albumTitle \| year)` | Compilations, inconsistent tags. May merge different releases with the same title |

**Album artist** (`albums.artist_id`) is determined when building the album:
1. Most common `albumArtist` tag among tracks
2. If all tracks share one artist — that artist
3. Otherwise — "Various Artists"

**Track artist** (`tracks.artist_id`) always comes from the `artist` tag (with fallback to `albumArtist` when `artist` is empty).

Modules: `album_grouping_strategy.dart`, `album_grouping.dart`, `entity_resolver.dart`, `cover_art_resolver.dart`.

## Scan rules

### File traversal

- Recursive traversal of all subfolders in the selected directory.
- Audio: `mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`.
- Skipped: `.wave_catcher` directory and legacy `.covers`, `.music_player`, plus `library.db` at the library root.

### Metadata

| Field | Source | Fallback |
|-------|--------|----------|
| Track title | file tags | filename without extension |
| Track artist | `artist` tag | `albumArtist` tag, then "Unknown Artist" |
| Album artist (tag) | `albumArtist` tag | — |
| Album | `album` tag | parent folder name, then "Unknown Album" |

### Cover art

Image extensions on disk: `jpg`, `jpeg`, `png`, `webp`.

**Track:**
1. Embedded cover from metadata → cache in `.wave_catcher/covers/{trackId}.ext`
2. First image in the track folder

**Album:**
1. Cover from any album track (embedded or from folder)
2. First image in any album track folder

### Tag encoding

Some MP3 files (especially older Russian-language ones) store tags in **Windows-1251**, but ID3 marks them as **Latin-1**. As a result, `metadata_god` returns mojibake like `Ôèëüòðóþùèé` instead of properly decoded Cyrillic text.

During scanning, `TagTextFixer` attempts to fix such strings: `latin1.encode` → `windows1251.decode`. The fix applies only to the index in `library.db`; files on disk are not modified.

The heuristic accepts the result if it contains ≥ 2 Cyrillic letters and Cyrillic letters account for ≥ 30% of all letters. ASCII and already-correct Cyrillic strings are left unchanged.

To apply the fix to an already indexed library, use **Settings → Rescan**.

### Identifiers

Deterministic SHA-256 hashes:

- `artistId` — from normalized **track** artist name
- `albumId` — depends on the selected grouping strategy (see "Album grouping")
- `trackId` — from absolute file path

## Scanner pipeline

```
ScanJob → FileDiscovery → MetadataExtractor → TagTextFixer → EntityResolver
        → CoverArtResolver → LibraryPersister → .wave_catcher/library.db
```

Directory: `lib/services/scanner/`

| Module | Responsibility |
|--------|----------------|
| `file_discovery.dart` | recursive traversal, audio filter |
| `metadata_extractor.dart` | read tags via `metadata_god` |
| `tag_text_fixer.dart` | fix CP1251 mojibake in text fields |
| `entity_resolver.dart` | fallback values, stable IDs, grouping strategy |
| `album_grouping.dart` | compute `albumId` and album artist |
| `album_grouping_strategy.dart` | strategy enum, UI labels |
| `cover_art_resolver.dart` | track and album covers |
| `library_persister.dart` | sync index to SQLite (`syncLibrary`) |
| `library_scanner_service.dart` | orchestrator, progress, `scanSingleFile` |

## Single-file incremental indexing

`LibraryScannerService.scanSingleFile` — full scanner pipeline for one path (without a full library rescan). Used when saving a track from **Explore** (`TrackImportService`):

1. `open(musicRoot)` on `LibraryRepository`
2. metadata extraction, override, album grouping
3. `upsertTrack` in SQLite
4. after writing to `import_sources` — `LibraryService.refreshOverrides()`

Import details: [explore.md](explore.md).

## Rescan

A full rescan (**Settings → Rescan**) syncs the index with disk; it does not recreate the database from scratch.

`LibraryPersister` calls `LibraryRepository.syncLibrary`:

1. **Upsert** all found `artists`, `albums`, `tracks` (same as `scanSingleFile`).
2. **Delete** from the index tracks whose `file_path` is not among scan results.
3. **`deleteOrphanedArtistsAndAlbums()`** — remove albums/artists with no tracks (e.g. after changing grouping strategy).
4. Clean orphan rows in `playlist_tracks` and `import_sources` for deleted tracks.

| Data | Behavior on rescan |
|------|-------------------|
| Files on disk | Re-read; metadata and covers updated |
| `trackId` | Stable while file path unchanged (`hash(filePath)`) |
| Playlists, Favorites, Saved | **Preserved** for tracks whose files still exist |
| Tracks with deleted files | Removed from index and playlists |
| `import_sources` (Explore) | Orphan rows for missing files removed |
| `indexed_at_ms` | Updated for all scanned tracks |

When opening `library.db`, `PRAGMA foreign_keys = ON` is enabled — cascade deletion of playlist links when a track is removed behaves predictably.

The `Imports/` folder (tracks from Explore) is scanned like the rest of the library.

## Layers

```
UI → LibraryService / LibraryScannerService / SettingsService
   → LibraryRepository / AppSettingsRepository
   → SQLite / filesystem
```

## Dependencies

- `file_picker` — folder selection (macOS / Windows / Linux)
- `metadata_god` — read audio tags
- `windows1251` — CP1251 decoding when fixing mojibake
- `sqlite3` + `sqlite3_flutter_libs` — SQLite on desktop
- `path_provider` — Application Support

## Environment setup (macOS)

`metadata_god` uses a native Rust/XCFramework. After `flutter pub get`, run:

```bash
cd macos && pod install && cd ..
flutter run -d macos
```

Without `pod install`, the app crashes with `store_dart_post_cobject: symbol not found`.

Minimum macOS version: **12.0** (metadata_god XCFramework requirement).

For release builds, aggressive strip optimization is disabled in `macos/Runner/Configs/Release.xcconfig` so the linker does not remove FFI symbols.

### App Sandbox

The app **does not use App Sandbox** — it is a desktop player that needs recursive access to the chosen music folder and write access to `.wave_catcher/library.db` inside it. Sandbox without security-scoped bookmarks blocks the folder picker and file access after restart.

## Out of scope

- Full incremental rescan by `file_modified_ms` (only targeted `scanSingleFile`)
- "Recently played"

Playback is documented separately: [player.md](player.md).  
YouTube Music import: [explore.md](explore.md).
