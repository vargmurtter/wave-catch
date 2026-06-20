# Design requirements

Normative document for waveCatcher UI layout. For any new layout or interface change, consult this file.

The current shell implementation is described separately: [features/ui-shell.md](features/ui-shell.md).

## Concept

- **Platform:** desktop app (macOS, Windows, Linux).
- **Reference:** Spotify — layout, density, dark theme, horizontal sections with cards.
- **Difference from Spotify:** accent color is red, not green.
- **UI state:** visual decisions do not depend on real data being present; mocks are acceptable, but layout must be production-ready.

## Color palette

All colors go through `AppColors` in `lib/ui/theme/app_colors.dart`. Do not hardcode hex values in widgets.

| Token | Value | Purpose |
|-------|-------|---------|
| `background` | `#121212` | Content area background |
| `sidebar` | `#000000` | Sidebar base color |
| `surface` | `#181818` | Cards, element backgrounds |
| `surfaceElevated` | `#282828` | Hover, selection |
| `accent` | `#FF4848` (RGB 255, 72, 72) | Accent: active icons, play button, progress |
| `sidebarOverlay` | `#D9000000` | Sidebar with blur |
| `surfaceOverlay` | `#CC181818` | Pop-up panels with blur |
| `playerOverlay` | `#D9181818` | Player with blur |
| `queueOverlay` | `#E6181818` | Queue panel with blur |
| `textPrimary` | `#FFFFFF` | Headings, titles |
| `textSecondary` | `#B3B3B3` | Artists, captions |
| `divider` | `#3E3E3E` | Dividers, panel borders |
| `hover` | `#33FFFFFF` | Hover highlight (semi-transparent white) |

Theme: `AppTheme.dark` in `lib/ui/theme/app_theme.dart`.

## Typography

| Element | Style | Size / weight |
|---------|-------|---------------|
| Screen title | `headlineMedium` | 24px, w700 |
| Section title | `titleLarge` | 20px, w700 |
| Card / track title | custom | 14px, w600 |
| Artist / caption | `bodyMedium` / custom | 13–14px, w400, `textSecondary` |
| Small text | `bodySmall` | 12px |

## Shell layout

Three zones; the player is always visible:

```
┌──────────┬─────────────────────────────────────┬──────────┐
│ Sidebar  │         Content Area                │  Queue   │
│  240px   │         (active screen)             │ (opt.)   │
│          │                                     │  350px   │
├──────────┴─────────────────────────────────────┴──────────┤
│                      PlayerBar  96px                      │
└───────────────────────────────────────────────────────────┘
```

| Zone | Width / height | Behavior |
|------|----------------|----------|
| Sidebar | 240px | Fixed width, navigation |
| Content | `Expanded` | Vertical scroll, screen switching |
| Queue panel | 350px | Appears on the right via player button |
| Player | 96px height | Full width, does not overlap content |

Root widget: `AppShell` (`lib/ui/shell/app_shell.dart`).

## Navigation (sidebar)

Six items, Lucide icons:

| Item | Icon |
|------|------|
| Home | `LucideIcons.house` |
| Explore | `LucideIcons.compass` |
| Artists | `LucideIcons.users` |
| Albums | `LucideIcons.disc3` |
| Playlists | `LucideIcons.listMusic` |
| Settings | `LucideIcons.settings` |

States:
- **Active:** red icon, bold text, `surfaceElevated` background with transparency.
- **Hover:** light highlight (`AppColors.hover`), `MouseRegion` + `SystemMouseCursors.click`.

## Home screen

Up to four sections, each with a title + horizontal card scroll when data is present:

1. **Recently played** — compact track cards (`RecentTrackTile`). *UI exists; playback history is not implemented — section stays hidden.*
2. **Recently added** — last indexed tracks as `RecentTrackTile`
3. **Favorite albums** — *label only*; currently lists all albums from the library (not the Favorites playlist)
4. **Favorite artists** — *label only*; currently lists all artists from the library

When implementing real favorites or recently played, update `LibraryService.getHomeSections()` and these labels.

## Player (PlayerBar)

Three columns, Spotify-style:

**Left:** 56px cover art + track title + artist.

**Center:** shuffle · prev · play/pause · next · repeat.

**Right:** queue button (`listMusic`) · volume (popup slider).

Additionally:
- 2px progress bar above controls, `accent` color.
- Shuffle / repeat highlighted with `accent` when active.
- Repeat cycle: off → all → one (`repeat` / `repeat1`).
- Play button — red circular background (`accent`).

## Visual effects (blur and transparency)

Use the `FrostedPanel` widget (`lib/ui/widgets/common/frosted_panel.dart`):
- `BackdropFilter` + semi-transparent `color` from overlay tokens.
- Apply to: sidebar, player, queue panel, volume popup.

**This is not glassmorphism:** no glass borders, highlights, or gradient borders. Only soft blur and muted transparency.

Hover on cards: light `AnimatedScale` (1.03) and shadow — **only in horizontal lists**, not in grids.

## Icons

- Package: `lucide_icons_flutter`.
- All UI icons are Lucide. Do not use Material Icons (except Flutter's internal mechanisms).

## Scroll and spacing

### Vertical screen scroll

- `SingleChildScrollView` / `ScreenScrollView` — **no outer padding**.
- Inner padding only on content inside:
  - screen title: `top 24`, horizontal `32`;
  - section titles and grids: horizontal `32`;
  - list bottom padding: `32`.

### Horizontal lists

- Section: `ContentSection(fullBleedChild: true)` — title with padding, list full width.
- Horizontal padding — inside `ListView` (`horizontalPadding: 32`).
- Visible `Scrollbar` required (`thumbVisibility: true`, `interactive: true`).

## Responsiveness and window

- **Minimum window size:** 900×640 px (`window_manager` in `lib/main.dart`).
- Grid cards: `LayoutBuilder`, cover size = cell width.
- Grids: `SliverGridDelegateWithMaxCrossAxisExtent` + `mainAxisExtent` (not `childAspectRatio`).
  - Albums: `mainAxisExtent: 250`
  - Artists: `mainAxisExtent: 220`
- In grids: `enableHoverScale: false` on `AlbumCard` / `ArtistCard` — avoid overflow.

## Code patterns

| Task | Widget / file |
|------|----------------|
| Scrollable screen | `ScreenScrollView` |
| Section with full-bleed list | `ContentSection(fullBleedChild: true)` |
| Horizontal list | `HorizontalCardList` |
| Cover placeholder | `CoverArt` (gradient by `seed`) |
| Blur panel | `FrostedPanel` |
| Colors and theme | `AppColors`, `AppTheme` |

Directory structure: `lib/ui/screens/`, `lib/ui/widgets/`, `lib/ui/theme/`, `lib/ui/shell/`.

## Anti-patterns

| Don't | Why | Do instead |
|-------|-----|------------|
| `Padding` around `SingleChildScrollView` | Content "vanishes into empty space" when scrolling | Padding inside child, `ScreenScrollView` |
| Fixed 160px cover in grid | `bottom overflowed` | `LayoutBuilder`, cover = cell width |
| `childAspectRatio` without text allowance | Overflow below cover | `mainAxisExtent` with room for 2 text lines |
| `AnimatedScale` in GridView | Scale exceeds cell bounds | `enableHoverScale: false` |
| Material Icons in UI | Breaks design system | Lucide Icons |
| Opaque sidebar/player background | Breaks established style | `FrostedPanel` + overlay tokens |
| Glassmorphism (borders, highlights) | Explicit user ban | Blur + opacity only |
| Hardcoded colors in widgets | Drifts from theme | `AppColors.*` |
| Horizontal list without Scrollbar | Content hidden in narrow window | `Scrollbar` + min window size |

## Examples

### Screen scroll

```dart
// ❌ Bad — outer padding on scroll area
Padding(
  padding: EdgeInsets.all(32),
  child: SingleChildScrollView(...),
)

// ✅ Good — zero scroll padding, padding on content
ScreenScrollView(
  child: Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: 24),
        child: ScreenHeader(title: 'Home'),
      ),
      ContentSection(
        title: 'Favorite albums',
        fullBleedChild: true,
        child: HorizontalCardList(...),
      ),
    ],
  ),
)
```

### Grid card

```dart
// ❌ Bad — fixed size, hover scale
AlbumCard(album: album)

// ✅ Good — adaptive layout, no scale
AlbumCard(album: album, enableHoverScale: false)
```

### Blur panel

```dart
// ❌ Bad — opaque Container
Container(color: AppColors.surface, child: player)

// ✅ Good
FrostedPanel(
  color: AppColors.playerOverlay,
  blurSigma: 24,
  border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
  child: player,
)
```
