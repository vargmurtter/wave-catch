# Artist information (MusicBrainz + Wikipedia)

Lazy-loads artist description and photo when opening the detail screen. Sources are MusicBrainz (lookup and links) and Wikipedia/Wikidata (bio and image). Data is cached on disk; on error the UI is unchanged.

No API keys required.

## UI behavior

`ArtistDetailScreen` when data is available shows:

- **Hero banner** full width (220 px) — photo from Wikipedia/Wikidata, `BoxFit.cover` + gradient
- **Round cover** (200 px) — external photo replaces cover inherited from album
- **Description** — up to 6 lines (ru Wikipedia → en Wikipedia → Wikidata description)

Loading runs only on the detail screen (`artistInfoProvider`). After caching, the image appears everywhere via `artistDisplayImagePathProvider` (cards, search, detail screen) — no repeated network requests.

While loading or on error — current layout unchanged.

## Architecture

```
ArtistDetailScreen
    → artistInfoProvider (FutureProvider.family)
    → ArtistInfoService
        → ArtistInfoCacheRepository (disk)
        → MusicBrainzApiRepository (search + url-rels)
        → WikipediaApiRepository (summary + Wikidata)
```

| Module | Layer | Purpose |
|--------|-------|---------|
| `MusicBrainzApiRepository` | Repository | MBID search, Wikipedia/Wikidata URL extraction |
| `WikipediaApiRepository` | Repository | REST summary, Wikidata EntityData |
| `ArtistInfoCacheRepository` | Repository | JSON cache + image download |
| `ArtistInfoService` | Service | cache-first logic, in-memory cache |
| `artistInfoProvider` | DI | lazy load by `artistId` |

## Data flow

1. MusicBrainz search: `GET /ws/2/artist?query=artist:"{name}"&fmt=json&limit=5`
2. MBID selection: exact name match or highest score
3. MusicBrainz lookup: `GET /ws/2/artist/{mbid}?inc=url-rels&fmt=json`
4. Wikipedia: `GET https://ru.wikipedia.org/api/rest_v1/page/summary/{title}` (fallback: en)
5. Wikidata (if needed): `GET .../Special:EntityData/{id}.json` — sitelinks, description, P18 → Commons
6. Download image to disk, write to cache

## MusicBrainz

- User-Agent required: `Wave Catch/0.1.0 (desktop music player)`
- Rate limit: **1 request per second** — throttle in `MusicBrainzApiRepository`

## Cache

Files in `{ApplicationSupport}/.wave_catcher/`:

| File | Contents |
|------|----------|
| `artist_info_cache.json` | `{ artistId: { description?, imagePath?, cachedAt } }` |
| `artist_images/{artistId}.{ext}` | Local photo copy |

Key is `artist.id` (hash of normalized name from library).

Successful responses cached indefinitely. Failed requests are not cached.

## Related files

- `lib/repositories/musicbrainz_api_repository.dart`
- `lib/repositories/wikipedia_api_repository.dart`
- `lib/repositories/artist_info_cache_repository.dart`
- `lib/services/artist_info_service.dart`
- `lib/ui/screens/artist_detail_screen.dart`
- `lib/ui/widgets/artist/artist_hero_banner.dart`

## Last.fm (inactive)

Last.fm code is preserved but not wired up: [lastfm-artist-info.md](lastfm-artist-info.md).
