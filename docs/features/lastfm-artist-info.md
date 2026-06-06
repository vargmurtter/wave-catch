# Last.fm: информация об исполнителе

> **Статус: отключено.** Код сохранён в `lib/repositories/lastfm_api_repository.dart` и методах настроек для возможного включения в будущем. Активный источник данных — [artist-info.md](artist-info.md) (MusicBrainz + Wikipedia).

Lazy-загрузка описания и фото исполнителя с Last.fm при открытии экрана деталей. Данные кэшируются на диск; при ошибке UI не меняется.

## Настройка

1. Получите API key на [last.fm/api/account/create](https://www.last.fm/api/account/create).
2. Введите ключ в **Настройки → Last.fm**.

Без ключа интеграция не активируется — экран исполнителя работает как раньше.

## Поведение UI

Экран `ArtistDetailScreen` при наличии данных Last.fm показывает:

- **Hero-баннер** на всю ширину (220 px) — квадратное фото Last.fm с `BoxFit.cover` и gradient
- **Круглую обложку** (200 px) — фото Last.fm заменяет обложку, унаследованную от альбома
- **Описание** — до 6 строк, plain text после strip HTML

Загрузка запускается только на экране деталей (`artistInfoProvider`). Списки и карточки исполнителей не затрагиваются.

Пока данные загружаются или при ошибке — текущий layout без изменений.

## Архитектура

```
ArtistDetailScreen
    → artistInfoProvider (FutureProvider.family)
    → ArtistInfoService
        → ArtistInfoCacheRepository (диск)
        → LastFmApiRepository (HTTP)
        → SettingsService (API key)
```

| Модуль | Слой | Назначение |
|--------|------|------------|
| `LastFmApiRepository` | Repository | `artist.getInfo`, парсинг bio и image URL |
| `ArtistInfoCacheRepository` | Repository | JSON-кэш + скачивание изображений |
| `ArtistInfoService` | Service | cache-first логика, in-memory кэш |
| `artistInfoProvider` | DI | lazy-загрузка по `artistId` |

## API

- Endpoint: `GET https://ws.audioscrobbler.com/2.0/?method=artist.getinfo`
- Параметры: `artist`, `api_key`, `format=json`, `lang=ru`, `autocorrect=1`
- Из ответа: `artist.bio.summary`, лучшее изображение (`mega` → `extralarge` → …)
- Placeholder-URL Last.fm игнорируются

## Кэш

Файлы в `{ApplicationSupport}/.wave_catcher/`:

| Файл | Содержимое |
|------|------------|
| `lastfm_artist_cache.json` | `{ artistId: { description?, imagePath?, cachedAt } }` |
| `lastfm_images/{artistId}.{ext}` | Локальная копия фото |

Ключ — `artist.id` (hash нормализованного имени из библиотеки).

Успешные ответы кэшируются навсегда. Неудачные запросы не кэшируются.

## Связанные файлы

- `lib/repositories/lastfm_api_repository.dart`
- `lib/repositories/artist_info_cache_repository.dart`
- `lib/services/artist_info_service.dart`
- `lib/ui/screens/artist_detail_screen.dart`
- `lib/ui/widgets/artist/artist_hero_banner.dart`
