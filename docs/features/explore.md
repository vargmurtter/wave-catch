# Explore (YouTube Music)

The **Explore** section (`NavItem.explore`) — search and preview tracks from YouTube Music without automatic saving. The user explicitly saves favorites to the local library.

Global search in the sidebar still works **only on the local library**. YouTube Music search is available only on the Explore screen.

## UX

| Element | Behavior |
|---------|----------|
| Search | Query YouTube Music, suggestions while typing |
| Results | Track list with cover, artist, duration |
| Play | Preview stream via yt-dlp; **Preview** badge in player |
| Save | Download MP3 to library, write tags, index; track is automatically added to the system **Saved** playlist |
| In library | Track already saved — button disabled |
| Recommendations | "You might like" — card grid (up to 30 tracks); up to 5 latest Explore imports → `getUpNexts` for each |
| yt-dlp missing | Prompt to install binary; preview and save unavailable |
| Empty library | Hint to add music for recommendations |
| No Explore imports | Hint to save tracks from search |
| Library rescan | **Saved** and "saved" status in Explore persist while MP3 is on disk; when file is deleted, track disappears from index, playlist, and `import_sources` |

## Architecture

```
ExploreScreen (UI)
    ↓
exploreServiceProvider, ytdlpAvailableProvider
    ↓
ExploreService ──────────────► YtmInnerTubeRepository (InnerTube API)
    │                              search, suggestions, Up Next
    ├── LibraryService / LibraryRepository (savedVideoIds, recommendations)
    └── ImportSourceRepository (video_id ↔ file_path)

PlayerBar "Save"
    ↓
TrackImportService
    ↓
YtdlpRepository.downloadAudio → MetadataFileWriter → LibraryScannerService.scanSingleFile
    ↓
ImportSourceRepository.upsert → PlaylistRepository.addTrack(Saved) → LibraryService.refresh
```

### Playback

`PlayerService` supports two queue item types — `PlayableItem`:

| Type | Source | Playback |
|------|--------|----------|
| `LocalPlayableItem` | `Track` from library | `media_kit` → local file |
| `RemotePlayableItem` | `ExploreTrack` | `YtdlpRepository.getStreamUrl` → `media_kit` → HTTP stream |

Stream URL cache in `PlayerService` (TTL ~4 h, see `YtdlpRepository`).

## Save to library

Path: `{musicRoot}/Imports/{Artist}/{Title}.mp3`

1. Download audio via yt-dlp (`bestaudio`, convert to MP3).
2. Write tags (`title`, `artist`, `album`, `albumArtist`, `year`, cover from thumbnail URL).
3. Single-file incremental indexing — `LibraryScannerService.scanSingleFile`.
4. Write `video_id` → `file_path` mapping to `import_sources` (DB schema v3).
5. Add track to system **Saved** playlist (`__saved_from_explore__`, DB schema v5). See [playlists.md](playlists.md).

Re-saving the same `video_id` returns the already indexed track and re-adds it to **Saved** if needed.

### After rescan

Rescan syncs the index with disk via `syncLibrary` (see [library-scanning.md](library-scanning.md)):

- MP3 files in `{musicRoot}/Imports/` remain in the library; **Saved** playlist and "saved" icon in Explore are not reset.
- If the file is deleted from disk, rescan removes the track from the index, playlist, and `import_sources` table.

## yt-dlp

Preview and save require the [yt-dlp](https://github.com/yt-dlp/yt-dlp) binary.

### Binary resolution (`YtdlpBinaryResolver`)

Lookup order:

1. Bundled binary in app bundle (`flutter_assets/assets/bin/{macos,linux,windows}/`) — run in place, no copy
2. Linux fallback: if bundle file is not executable — `chmod +x` or one-time copy to `.wave_catcher/bin/`
3. System PATH / Homebrew (`yt-dlp`) — only when no bundled binary in the build

Prepare bundle for development and release:

```bash
./scripts/fetch_ytdlp.sh
```

Alternative: `brew install yt-dlp` (macOS) or install to PATH on Linux/Windows.

### YouTube cookies (age-restricted)

Search via InnerTube works without auth, but **preview and save** of age-restricted videos require cookies from a YouTube account with verified age.

In **Settings → yt-dlp → YouTube authorization**, modes:

| Mode | yt-dlp flag | Description |
|------|-------------|-------------|
| No cookies | — | Default; age-restricted tracks unavailable |
| From file | `--cookies path/to/cookies.txt` | Netscape format (browser extension export or `yt-dlp --cookies-from-browser … --cookies cookies.txt`) |
| From browser | `--cookies-from-browser chrome` | Cookies from installed browser; YouTube login required |

Settings stored in `app_config.json` (`ytdlpCookieSource`, `ytdlpCookiesFilePath`, `ytdlpBrowser`). Changing mode clears stream URL cache.

Model: `YtdlpAuthSettings` in `lib/repositories/ytdlp_auth_settings.dart`.

## YouTube Music API

`YtmInnerTubeRepository` — direct InnerTube requests, no official YouTube Data API:

- `searchSongs` — track search
- `searchSuggestions` — suggestions
- `getUpNexts` — similar / Up Next (radio from seed track)

UI model: `ExploreTrack` (`videoId`, `watchUrl`, `thumbnailUrl`, `title`, `artist`, `album`, `duration`, …).

## Database

`import_sources` table (v3 migration in `library_database.dart`):

| Column | Description |
|--------|-------------|
| `video_id` | YouTube video ID (PK) |
| `file_path` | Absolute path to saved file (UNIQUE) |
| `saved_at_ms` | Save timestamp |

Repository: `ImportSourceRepository` — always through current `LibraryRepository`, does not cache a closed SQLite connection.

## Files

| File | Purpose |
|------|---------|
| `lib/ui/screens/explore_screen.dart` | Section screen |
| `lib/ui/widgets/explore/explore_track_tile.dart` | Track row (search) |
| `lib/ui/widgets/explore/explore_track_card.dart` | Track card (recommendations) |
| `lib/ui/models/explore_track.dart` | YouTube Music track model |
| `lib/ui/models/playable_item.dart` | `LocalPlayableItem` / `RemotePlayableItem` |
| `lib/ui/models/playback_mode.dart` | `library` / `explore` |
| `lib/services/explore_service.dart` | Search, recommendations, `isAlreadySaved` |
| `lib/services/track_import_service.dart` | Save to library |
| `lib/repositories/ytm_innertube_repository.dart` | InnerTube client |
| `lib/repositories/ytdlp_repository.dart` | stream URL, download, cache |
| `lib/repositories/ytdlp_auth_settings.dart` | yt-dlp cookie settings |
| `lib/repositories/ytdlp_binary_resolver.dart` | Binary lookup |
| `lib/repositories/import_source_repository.dart` | CRUD for `import_sources` |
| `scripts/fetch_ytdlp.sh` | Download standalone binaries to assets |

## Providers

| Provider | Purpose |
|----------|---------|
| `exploreServiceProvider` | Search and recommendations |
| `trackImportServiceProvider` | Save track |
| `ytmInnerTubeRepositoryProvider` | InnerTube client |
| `ytdlpRepositoryProvider` | yt-dlp operations |
| `ytdlpAvailableProvider` | Binary availability |
| `ytdlpVersionProvider` | yt-dlp version |

## Limitations (MVP)

- Track search only; YouTube Music albums and playlists not implemented.
- Recommendations: 5 latest Explore imports → `getUpNexts` → round-robin merge (up to 30 tracks); no Charts/Moods.
- No MusicBrainz enrichment on import.
- No yt-dlp codesign on macOS — if Gatekeeper blocks, use Homebrew or allow manually.
- Preview requires network; local library works offline.

## Related documents

- [player.md](player.md) — queue, `PlayableItem`, preview stream
- [playlists.md](playlists.md) — Saved system playlist
- [library-scanning.md](library-scanning.md) — `scanSingleFile`, DB schema
- [library-search.md](library-search.md) — local search (separate from Explore)
