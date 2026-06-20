# Playback (PlayerService)

Playback of local audio files and preview streams from YouTube Music via [media_kit](https://pub.dev/packages/media_kit) (libmpv). The player UI reads state from `playerUiStateProvider`, which delegates to `PlayerService`.

## Formats (local library)

Supported extensions match library scanning:

`mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`

Source list: `kAudioExtensions` in `lib/services/scanner/scan_rules.dart`.

Previews from **Explore** are HTTP streams; the URL is obtained via yt-dlp (see [explore.md](explore.md)).

## Architecture

```
UI (PlayerBar, QueuePanel, ExploreScreen, TrackListTile, …)
    ↓ playerUiStateProvider
PlayerService
    ↓                    ↓                    ↓
LibraryService      media_kit Player      YtdlpRepository (opt.)
    ↓
LibraryRepository
```

- **`PlayerService`** (`lib/services/player_service.dart`) — queue, repeat/shuffle, local and remote sources.
- **`playerServiceProvider`** — creates the service, calls `dispose()` on teardown.
- **`PlayerUiStateNotifier`** — subscribes to the service `stateStream`, proxies UI actions.

Initialization: `MediaKit.ensureInitialized()` in `lib/main.dart`.

## Queue items (`PlayableItem`)

The queue and current track are described by the sealed class `PlayableItem`, not only `Track`:

| Type | Model | `playbackMode` | Source for media_kit |
|------|-------|----------------|------------------------|
| `LocalPlayableItem` | `Track` | `library` | `file://` — path to file |
| `RemotePlayableItem` | `ExploreTrack` | `explore` | HTTP URL from `YtdlpRepository.getStreamUrl` |

Cover art in the player: local tracks — `imagePath` (file on disk); previews — `imageUrl` (YouTube Music thumbnail). The `CoverArt` widget uses `Image.network` only for `http://` / `https://`.

## Player state (`PlayerUiState`)

| Field | Description |
|-------|-------------|
| `currentItem` | Current `PlayableItem` or `null` (empty player) |
| `currentTrack` | `Track?` — local item only (convenience getter) |
| `playbackMode` | `library` / `explore` — from `currentItem` |
| `isExplorePlayback` | `true` for Explore preview |
| `queue` | Current queue (`List<PlayableItem>`) |
| `queueIndex` | Index of current item in queue |
| `isPlaying` | Playing / paused |
| `shuffleEnabled` | Random order |
| `repeatMode` | `off` / `all` / `one` |
| `volume` | 0.0–1.0 |
| `position`, `duration` | Progress (from media_kit) |
| `progress` | Computed: `position / duration` |
| `isQueueOpen` | Queue panel visibility |

## Queue rules (library)

| Action | Queue | Start |
|--------|-------|-------|
| Play album | Album tracks (`track_number`, `title`) | First track |
| Play track in album | Album tracks | Selected track |
| Play artist | All artist tracks (`title`) | First (or selected) |
| Play all (Home) | All library tracks, **shuffled** | First track; `shuffleEnabled = true` |

When shuffle is enabled before starting an album/artist, the starting track stays first; the rest are shuffled.

## Explore queue

| Action | Method | Queue |
|--------|--------|-------|
| Play in Explore | `playExploreTrack` | One track or list of `ExploreTrack` |
| Save from player | `TrackImportService` + `replaceCurrentExploreWithLocal` | Current remote item replaced with `LocalPlayableItem` |

Previews are not saved to disk automatically.

## Repeat and shuffle

- **Repeat off** — stop after the last track.
- **Repeat all** — after the last track → first track.
- **Repeat one** — loop current track.
- **Shuffle toggle** — shuffles items **after** the current one; when disabled, restores order from the base queue.

## Prev / Next

- **Next** — next item respecting repeat; with `repeat one` — seek to start.
- **Previous** — if played > 3 s, seek to start; otherwise previous track (or last with `repeat all` on first track).

## UI entry points

| Location | Method |
|----------|--------|
| Hover play in `TrackListTile` (default) | `playTrackInAlbum` |
| Hover play in `TrackListTile` on playlist screen | `playPlaylist` (with `startTrack`) |
| Play button on playlist screen | `playPlaylist` |
| Play button on album | `playAlbum` |
| Play button on artist / "All tracks" | `playArtist` |
| Play all on Home | `playAllShuffled` |
| Track click in search | `playTrackInAlbum` |
| Play button in `TrackInfoPanel` | `playTrackInAlbum` |
| Play in `ExploreScreen` / `ExploreTrackTile` | `playExploreTrack` |
| Click in `QueuePanel` | `jumpToIndex` |

## PlayerBar (Explore)

When `isExplorePlayback`:

- **Preview** badge;
- **Save to library** button (if yt-dlp is available and track not yet saved);
- **In library** state for already imported `video_id`.

## Dependencies

```yaml
media_kit: ^1.2.6
media_kit_libs_audio: ^1.0.7
```

The `media_kit_libs_audio` package bundles native libmpv binaries for macOS, Windows, and Linux.

Previews additionally depend on yt-dlp (see [explore.md](explore.md)).

## Out of scope

- User playlists (still mock)
- "Recently played" history
- System media keys / OS integration
- Auto-save preview to library
