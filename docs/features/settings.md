# Settings

The **Settings** screen (`settings_screen.dart`, sidebar nav item) groups app configuration. Each section delegates to services and persists values in `{ApplicationSupport}/.wave_catcher/app_config.json` unless noted otherwise.

## Sections

| Section | What it controls | Details |
|---------|------------------|---------|
| Language | UI locale (`languageCode`) | [localization.md](localization.md) |
| yt-dlp status | Bundled or system binary availability and version | [explore.md](explore.md) |
| YouTube authorization | Cookie source for age-restricted Explore preview/save | [explore.md](explore.md) |
| Music folder | Library root path | [library-scanning.md](library-scanning.md) |
| Rescan | Full library sync with disk | [library-scanning.md](library-scanning.md) |
| Album grouping | `albumGroupingStrategy` (requires rescan) | [library-scanning.md](library-scanning.md) |
| Metadata editing | Write-to-file vs override config mode | [metadata-editing.md](metadata-editing.md) |

## State and scan

- Settings state: `appSettingsStateProvider` → `SettingsService` → `AppSettingsRepository`
- Rescan progress: `libraryScanStateProvider` → `LibraryScannerService`

Changing the music folder or album grouping may prompt for an immediate rescan.

## Not in Settings UI

**Last.fm** — API key storage exists in `AppSettingsRepository`, but there is no Settings UI and `ArtistInfoService` does not use Last.fm. See [lastfm-artist-info.md](lastfm-artist-info.md).

## Related files

| File | Purpose |
|------|---------|
| `lib/ui/screens/settings_screen.dart` | Settings UI |
| `lib/services/settings_service.dart` | Read/write settings |
| `lib/repositories/app_settings_repository.dart` | `app_config.json` persistence |
| `lib/di/providers.dart` | `appSettingsStateProvider`, `libraryScanStateProvider` |
