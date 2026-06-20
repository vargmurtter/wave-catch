# UI shell

Detailed design requirements: [design-requirements.md](../design-requirements.md)

Desktop UI shell in Spotify style with a red accent. Library and playback are wired through `LibraryService`, `PlaylistService`, and `PlayerService`.

> This document describes the **current shell implementation**. Normative requirements for any future layout work are in [design-requirements.md](../design-requirements.md).

## Layout

```
┌──────────┬─────────────────────────────────────┬──────────┐
│          │                              ┌──────┤ Track  │
│ Sidebar  │         Content Area         │Queue │ Info   │
│  240px   │  (section or detail          │Panel │(overlay│
│          │   screen)                    │(opt.)│ opt.)  │
│          │                              │350px │ 350px  │
├──────────┴──────────────────────────────┴──────┴────────┤
│                      PlayerBar  96px                     │
└──────────────────────────────────────────────────────────┘
```

- **Sidebar** — navigation: Home, **Explore**, Artists, Albums, Playlists, Settings; global search field (local library only)
- **Content** — selected section screen, detail screen (artist, album, playlist), or search results
- **Player** — pinned at bottom, full width
- **Queue panel** — slides in from the right when the playlist button in the player is pressed
- **Track panel** — floating overlay on the right when clicking a track (not play)

Detail screens: [library-detail-screens.md](library-detail-screens.md). Playlists: [playlists.md](playlists.md). Settings: [settings.md](settings.md).

## Color scheme

| Token | Value | Purpose |
|-------|-------|---------|
| `background` | `#121212` | Content background |
| `sidebar` | `#000000` | Sidebar background |
| `surface` | `#181818` | Cards, player |
| `surfaceElevated` | `#282828` | Hover, active elements |
| `accent` | `#FF4848` (RGB 255, 72, 72) | Accent (instead of Spotify green) |
| `sidebarOverlay` | `#D9000000` | Semi-transparent sidebar with blur |
| `playerOverlay` | `#D9181818` | Semi-transparent player with blur |
| `textPrimary` | `#FFFFFF` | Primary text |
| `textSecondary` | `#B3B3B3` | Secondary text |

Theme files: `lib/ui/theme/app_colors.dart`, `lib/ui/theme/app_theme.dart`.

## Widget structure

```
lib/ui/
  shell/
    app_shell.dart          # root layout
  screens/
    home_screen.dart            # Home sections
    explore_screen.dart         # YouTube Music: search, recommendations, preview
    artists_screen.dart         # artist grid
    albums_screen.dart          # album grid
    playlists_screen.dart       # playlist list
    playlist_detail_screen.dart # playlist detail
    settings_screen.dart        # app settings
    onboarding_screen.dart      # first-run folder picker
    language_selection_screen.dart
    artist_detail_screen.dart   # artist detail
    artist_tracks_screen.dart   # all artist tracks
    album_detail_screen.dart    # album detail
    search_screen.dart          # global search results
  widgets/
    sidebar/                # AppSidebar, SidebarNavItem
    search/                 # GlobalSearchField, SearchResultTile
    player/                 # PlayerBar, VolumeControl, QueuePanel
    explore/                # ExploreTrackTile, ExploreTrackCard, save icons
    playlist/               # CreatePlaylistDialog, AddToPlaylistDialog
    home/                   # cards and sections
    track/                  # TrackListTile, TrackInfoPanel, FavoriteTrackButton
    common/                 # CoverArt, DetailBackButton, FrostedPanel, PlayActionButton
  models/                   # Track, Album, Artist, Playlist, ExploreTrack, …
  mock/
    mock_data.dart          # legacy test data (screens use real library)
```

## Providers (Riverpod)

| Provider | File | Purpose |
|----------|------|---------|
| `selectedNavItemProvider` | `lib/di/providers.dart` | Active sidebar item |
| `appSettingsStateProvider` | `lib/di/providers.dart` | Settings and library path |
| `libraryScanStateProvider` | `lib/di/providers.dart` | Scan progress |
| `libraryRefreshProvider` | `lib/di/providers.dart` | Invalidate library-derived UI |
| `playerUiStateProvider` | `lib/di/providers.dart` | Player state (proxies `PlayerService`) |
| `playerServiceProvider` | `lib/di/providers.dart` | Playback service |
| `homeSectionsProvider` | `lib/di/providers.dart` | Home screen section data |
| `libraryRouteProvider` | `lib/di/providers.dart` | Detail route stack |
| `trackInfoPanelProvider` | `lib/di/providers.dart` | Floating track info panel |
| `playlistsProvider` | `lib/di/providers.dart` | All playlists |
| `playlistActionsProvider` | `lib/di/providers.dart` | Playlist CRUD and favorites |
| `isTrackFavoriteProvider` | `lib/di/providers.dart` | Favorites membership |
| `searchQueryProvider` | `lib/di/providers.dart` | Global search text |
| `librarySearchResultsProvider` | `lib/di/providers.dart` | Library search results |
| `exploreServiceProvider` | `lib/di/providers.dart` | YouTube Music search and recommendations |
| `ytdlpAvailableProvider` | `lib/di/providers.dart` | yt-dlp availability for Explore |

Search details: [library-search.md](library-search.md).  
Explore: [explore.md](explore.md).  
Player details: [player.md](player.md).  
Playlists: [playlists.md](playlists.md).

Player buttons and launch points call `PlayerUiStateNotifier` → `PlayerService`. Library data goes through `LibraryService`; playlists through `PlaylistService`.

## Minimum window size

900×640 px (via `window_manager` in `lib/main.dart`). Horizontal lists on the Home screen have a visible `Scrollbar`.

## Home screen scroll

Vertical scroll area has no outer padding. Inner padding (32 px) applies to titles and grids; horizontal lists scroll full width with padding inside `ListView`.

See [design-requirements.md](../design-requirements.md) for section naming vs current data behavior.

## Icons

Uses the `lucide_icons_flutter` package. All UI icons are from the Lucide set.

## Placeholders

- Covers without a file use gradient placeholders via `CoverArt`
