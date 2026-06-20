# Last.fm: artist information

> **Status: disabled.** Code is preserved in `lib/repositories/lastfm_api_repository.dart` and settings methods for possible future enablement. Active data source — [artist-info.md](artist-info.md) (MusicBrainz + Wikipedia).

Lazy-loads artist description and photo from Last.fm when opening the detail screen. Data is cached on disk; on error the UI is unchanged.

## Setup

1. Get an API key at [last.fm/api/account/create](https://www.last.fm/api/account/create).
2. Enter the key in **Settings → Last.fm**.

Without a key, integration is inactive — the artist screen works as before.

## UI behavior

`ArtistDetailScreen` when Last.fm data is available shows:

- **Hero banner** full width (220 px) — square Last.fm photo with `BoxFit.cover` and gradient
- **Round cover** (200 px) — Last.fm photo replaces cover inherited from album
- **Description** — up to 6 lines, plain text after HTML strip

Loading runs only on the detail screen (`artistInfoProvider`). Artist lists and cards are unaffected.

While loading or on error — current layout unchanged.

## Architecture

```
ArtistDetailScreen
    → artistInfoProvider (FutureProvider.family)
    → ArtistInfoService
        → ArtistInfoCacheRepository (disk)
        → LastFmApiRepository (HTTP)
        → SettingsService (API key)
```

| Module | Layer | Purpose |
|--------|-------|---------|
| `LastFmApiRepository` | Repository | `artist.getInfo`, bio and image URL parsing |
| `ArtistInfoCacheRepository` | Repository | JSON cache + image download |
| `ArtistInfoService` | Service | cache-first logic, in-memory cache |
| `artistInfoProvider` | DI | lazy load by `artistId` |

## API

- Endpoint: `GET https://ws.audioscrobbler.com/2.0/?method=artist.getinfo`
- Parameters: `artist`, `api_key`, `format=json`, `lang=ru`, `autocorrect=1`
- From response: `artist.bio.summary`, best image (`mega` → `extralarge` → …)
- Last.fm placeholder URLs are ignored

## Cache

Files in `{ApplicationSupport}/.wave_catcher/`:

| File | Contents |
|------|----------|
| `lastfm_artist_cache.json` | `{ artistId: { description?, imagePath?, cachedAt } }` |
| `lastfm_images/{artistId}.{ext}` | Local photo copy |

Key is `artist.id` (hash of normalized name from library).

Successful responses cached indefinitely. Failed requests are not cached.

## Related files

- `lib/repositories/lastfm_api_repository.dart`
- `lib/repositories/artist_info_cache_repository.dart`
- `lib/services/artist_info_service.dart`
- `lib/ui/screens/artist_detail_screen.dart`
- `lib/ui/widgets/artist/artist_hero_banner.dart`
