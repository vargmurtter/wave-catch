# Playlists

User playlists and two system playlists stored in `library.db`. Tracks are linked by ID; membership survives rescan while files remain on disk.

Rescan behavior: [library-scanning.md](library-scanning.md).

## System playlists

| ID | UI name | Purpose |
|----|---------|---------|
| `__favorites__` | Favorites (localized) | Heart toggle on tracks |
| `__saved_from_explore__` | Saved (localized) | Tracks imported from Explore |

System playlists cannot be deleted. Names in the UI come from `playlistDisplayName()` — not the raw DB name.

Explore import adds tracks to **Saved** automatically: [explore.md](explore.md).

## User playlists

- Create from **Playlists** screen (`CreatePlaylistDialog`) or from **Add to playlist** dialog
- Delete from Playlists list (user playlists only)
- Add/remove tracks via **Add to playlist** dialog
- Sort by date added: oldest first (ASC) or newest first (DESC) — per-playlist setting

## UX

| Element | Behavior |
|---------|----------|
| Playlists screen | List all playlists (system first), create button, delete on hover for user playlists |
| Playlist detail | Track list, Play all, per-track play, sort menu |
| Heart button | `FavoriteTrackButton` — toggles membership in Favorites |
| Add to playlist | `AddToPlaylistDialog` — checkboxes for playlists containing the track; create new playlist inline |
| Play from playlist | `playPlaylist(tracks, startTrack: …)` — see [player.md](player.md) |

## Database

Migrations in `library_database.dart`:

| Version | Change |
|---------|--------|
| v4 | `playlists`, `playlist_tracks`; Favorites system playlist |
| v5 | Saved system playlist; backfill from `import_sources` |
| v6 | `added_at_sort_asc` column for sort order |

### `playlists`

| Column | Description |
|--------|-------------|
| `id` | Primary key |
| `name` | Display name (system rows use English defaults in DB) |
| `is_system` | 1 = cannot delete |
| `created_at_ms` | Creation time |
| `added_at_sort_asc` | 1 = sort by `added_at_ms` ASC, 0 = DESC |

### `playlist_tracks`

| Column | Description |
|--------|-------------|
| `playlist_id` | FK → `playlists` |
| `track_id` | FK → `tracks` |
| `added_at_ms` | When track was added |

Composite primary key `(playlist_id, track_id)`. Cascade delete when playlist or track is removed.

## Architecture

```
PlaylistsScreen / PlaylistDetailScreen / dialogs (UI)
    ↓
playlistActionsProvider, playlistsProvider, …
    ↓
PlaylistService
    ↓
PlaylistRepository (via LibraryRepository.playlistRepository)
    ↓
library.db
```

Explore import and rescan also touch playlists:

```
TrackImportService → PlaylistRepository.addTrack(Saved)
LibraryPersister.syncLibrary → preserves playlist_tracks for existing files
```

## Files

| File | Purpose |
|------|---------|
| `lib/repositories/playlist_repository.dart` | SQL CRUD, sort order |
| `lib/services/playlist_service.dart` | Business logic, favorites toggle |
| `lib/ui/screens/playlists_screen.dart` | Playlist list |
| `lib/ui/screens/playlist_detail_screen.dart` | Playlist detail |
| `lib/ui/widgets/playlist/create_playlist_dialog.dart` | Create playlist |
| `lib/ui/widgets/playlist/add_to_playlist_dialog.dart` | Add/remove membership |
| `lib/ui/widgets/track/favorite_track_button.dart` | Heart + `AddToPlaylistButton` |
| `lib/ui/models/playlist.dart` | UI model |
| `lib/ui/models/playlist_sort_order.dart` | ASC / DESC enum |
| `lib/services/scanner/scan_rules.dart` | System playlist ID constants |

## Providers

| Provider | Purpose |
|----------|---------|
| `playlistServiceProvider` | Service instance |
| `playlistsProvider` | All playlists |
| `playlistByIdProvider` | Single playlist by ID |
| `tracksForPlaylistProvider` | Tracks in playlist (respects sort) |
| `isTrackFavoriteProvider` | Whether track is in Favorites |
| `trackPlaylistIdsProvider` | Playlist IDs containing a track |
| `playlistActionsProvider` | UI actions (create, delete, add, remove, sort, toggle favorite) |

## Related documents

- [player.md](player.md) — `playPlaylist`, queue from playlist detail
- [explore.md](explore.md) — Saved playlist on import
- [library-scanning.md](library-scanning.md) — rescan and orphan cleanup
- [library-detail-screens.md](library-detail-screens.md) — `PlaylistDetailRoute`
