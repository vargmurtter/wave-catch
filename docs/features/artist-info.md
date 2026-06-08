# Информация об исполнителе (MusicBrainz + Wikipedia)

Lazy-загрузка описания и фото исполнителя при открытии экрана деталей. Источники — MusicBrainz (поиск и ссылки) и Wikipedia/Wikidata (bio и изображение). Данные кэшируются на диск; при ошибке UI не меняется.

API keys не требуются.

## Поведение UI

Экран `ArtistDetailScreen` при наличии данных показывает:

- **Hero-баннер** на всю ширину (220 px) — фото с Wikipedia/Wikidata, `BoxFit.cover` + gradient
- **Круглую обложку** (200 px) — внешнее фото заменяет обложку, унаследованную от альбома
- **Описание** — до 6 строк (ru Wikipedia → en Wikipedia → Wikidata description)

Загрузка запускается только на экране деталей (`artistInfoProvider`). После кэширования изображение показывается везде через `artistDisplayImagePathProvider` (карточки, поиск, экран деталей) — без повторных сетевых запросов.

Пока данные загружаются или при ошибке — текущий layout без изменений.

## Архитектура

```
ArtistDetailScreen
    → artistInfoProvider (FutureProvider.family)
    → ArtistInfoService
        → ArtistInfoCacheRepository (диск)
        → MusicBrainzApiRepository (search + url-rels)
        → WikipediaApiRepository (summary + Wikidata)
```

| Модуль | Слой | Назначение |
|--------|------|------------|
| `MusicBrainzApiRepository` | Repository | Поиск MBID, извлечение Wikipedia/Wikidata URL |
| `WikipediaApiRepository` | Repository | REST summary, Wikidata EntityData |
| `ArtistInfoCacheRepository` | Repository | JSON-кэш + скачивание изображений |
| `ArtistInfoService` | Service | cache-first логика, in-memory кэш |
| `artistInfoProvider` | DI | lazy-загрузка по `artistId` |

## Поток данных

1. MusicBrainz search: `GET /ws/2/artist?query=artist:"{name}"&fmt=json&limit=5`
2. Выбор MBID: exact name match или highest score
3. MusicBrainz lookup: `GET /ws/2/artist/{mbid}?inc=url-rels&fmt=json`
4. Wikipedia: `GET https://ru.wikipedia.org/api/rest_v1/page/summary/{title}` (fallback: en)
5. Wikidata (если нужно): `GET .../Special:EntityData/{id}.json` — sitelinks, description, P18 → Commons
6. Скачивание изображения на диск, запись в кэш

## MusicBrainz

- User-Agent обязателен: `Wave Catch/0.1.0 (desktop music player)`
- Rate limit: **1 запрос в секунду** — throttle в `MusicBrainzApiRepository`

## Кэш

Файлы в `{ApplicationSupport}/.wave_catcher/`:

| Файл | Содержимое |
|------|------------|
| `artist_info_cache.json` | `{ artistId: { description?, imagePath?, cachedAt } }` |
| `artist_images/{artistId}.{ext}` | Локальная копия фото |

Ключ — `artist.id` (hash нормализованного имени из библиотеки).

Успешные ответы кэшируются навсегда. Неудачные запросы не кэшируются.

## Связанные файлы

- `lib/repositories/musicbrainz_api_repository.dart`
- `lib/repositories/wikipedia_api_repository.dart`
- `lib/repositories/artist_info_cache_repository.dart`
- `lib/services/artist_info_service.dart`
- `lib/ui/screens/artist_detail_screen.dart`
- `lib/ui/widgets/artist/artist_hero_banner.dart`

## Last.fm (неактивно)

Код Last.fm сохранён, но не подключён: [lastfm-artist-info.md](lastfm-artist-info.md).
