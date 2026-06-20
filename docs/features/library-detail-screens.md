# Library detail screens

Artist screen, album screen, and floating track info panel. Data from `LibraryService` via Riverpod providers.

Shell details: [ui-shell.md](ui-shell.md). Design requirements: [design-requirements.md](../design-requirements.md). Artist information: [artist-info.md](artist-info.md).

## Screens

### Artist (`ArtistDetailScreen`)

File: `lib/ui/screens/artist_detail_screen.dart`

- Full-width hero banner (when Wikipedia/Wikidata photo is available)
- Back button + round cover (200 px) + artist name
- Artist description (up to 6 lines)
- Albums section — horizontal `AlbumCard` list
- Popular tracks section — up to 5 tracks (`TrackListTile`) + "Show all" link

### All artist tracks (`ArtistTracksScreen`)

File: `lib/ui/screens/artist_tracks_screen.dart`

- Full artist track list without album grouping
- Album name shown in row subtitle

### Album (`AlbumDetailScreen`)

File: `lib/ui/screens/album_detail_screen.dart`

- Back button + square cover (200 px) + album title
- Clickable artist → artist screen
- Release year
- Numbered track list
- Other albums section — horizontal list of albums by the same artist

## Navigation

Detail screens are not added to the sidebar. Route stack via `libraryRouteProvider` (`List<LibraryRoute>`):

| Route | Opened by |
|-------|-----------|
| `LibraryMainRoute` | Default; reset when sidebar item changes |
| `ArtistDetailRoute` | Click on `ArtistCard` |
| `ArtistTracksRoute` | "Show all" on artist screen |
| `AlbumDetailRoute` | Click on `AlbumCard` or link in track panel |

`LibraryRouteNotifier` methods: `openArtist`, `openArtistTracks`, `openAlbum`, `goBack`, `reset`.

`_ContentArea` in `app_shell.dart` renders the screen at the top of the stack.

## Track info panel

File: `lib/ui/widgets/track/track_info_panel.dart`

Floating window over content, aligned to the right edge (above `PlayerBar`, 350 px). Does not replace the queue panel — both can be visible at once.

State: `trackInfoPanelProvider` (`Track?`).

Opened by: click on track row (`TrackListTile`, `RecentTrackTile`), not the play button.

Content:
- Cover, title
- Album and artist (clickable → detail screens)
- Year
- Metadata: duration, track number, genre, format, bitrate

## Track row widget

File: `lib/ui/widgets/track/track_list_tile.dart`

- Row click → `trackInfoPanelProvider.open(track)`
- Hover play button → `playTrackInAlbum(track)` — queue = album, start at selected track
- Play button on album / artist header → `playAlbum` / `playArtist`
- Parameters: `showTrackNumber`, `showArtist`, `showAlbum`

## Mock data

File: `lib/ui/mock/mock_data.dart` — used in early stages; screens now use the real library.

## Providers

| Provider | Purpose |
|----------|---------|
| `libraryRouteProvider` | Detail route stack |
| `trackInfoPanelProvider` | Open track in floating panel |
| `artistInfoProvider` | Load artist data (lazy, detail screen only) |
| `artistDisplayImagePathProvider` | Cover path: MB/Wiki cache → local album cover |
| `artistCachedImagePathProvider` | Cached photo only (no fallback) |
