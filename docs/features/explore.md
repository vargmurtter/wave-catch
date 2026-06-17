# Исследование (YouTube Music)

Раздел **«Исследование»** (`NavItem.explore`) — поиск и превью треков из YouTube Music без автоматического сохранения. Пользователь явно сохраняет понравившееся в локальную библиотеку.

Глобальный поиск в сайдбаре по-прежнему работает **только по локальной библиотеке**. Поиск YouTube Music доступен только на экране «Исследование».

## UX

| Элемент | Поведение |
|---------|-----------|
| Поиск | Запрос к YouTube Music, подсказки при вводе |
| Результаты | Список треков с обложкой, исполнителем, длительностью |
| Play | Превью-поток через yt-dlp; в плеере бейдж **«Превью»** |
| Сохранить | Скачивание MP3 в библиотеку, теги, индексация |
| В библиотеке | Трек уже сохранён — кнопка неактивна |
| Рекомендации | Топ-исполнители из библиотеки → Up Next / топ треков артиста |
| yt-dlp отсутствует | Подсказка установить бинарник; превью и сохранение недоступны |
| Пустая библиотека | Подсказка добавить музыку для рекомендаций |

## Архитектура

```
ExploreScreen (UI)
    ↓
exploreServiceProvider, ytdlpAvailableProvider
    ↓
ExploreService ──────────────► YtmInnerTubeRepository (InnerTube API)
    │                              search, suggestions, Up Next, artist top
    ├── LibraryService / LibraryRepository (savedVideoIds, рекомендации)
    └── ImportSourceRepository (video_id ↔ file_path)

PlayerBar «Сохранить»
    ↓
TrackImportService
    ↓
YtdlpRepository.downloadAudio → MetadataFileWriter → LibraryScannerService.scanSingleFile
    ↓
ImportSourceRepository.upsert → LibraryService.refresh
```

### Воспроизведение

`PlayerService` поддерживает два типа элементов очереди — `PlayableItem`:

| Тип | Источник | Воспроизведение |
|-----|----------|-----------------|
| `LocalPlayableItem` | `Track` из библиотеки | `media_kit` → локальный файл |
| `RemotePlayableItem` | `ExploreTrack` | `YtdlpRepository.getStreamUrl` → `media_kit` → HTTP-поток |

Кэш stream URL в `PlayerService` (TTL ~4 ч, см. `YtdlpRepository`).

## Сохранение в библиотеку

Путь: `{musicRoot}/Imports/{Artist}/{Title}.mp3`

1. Скачивание аудио через yt-dlp (`bestaudio`, конвертация в MP3).
2. Запись тегов (`title`, `artist`, `album`, `albumArtist`, `year`, обложка с thumbnail URL).
3. Инкрементальная индексация одного файла — `LibraryScannerService.scanSingleFile`.
4. Запись связи `video_id` → `file_path` в таблицу `import_sources` (схема БД v3).

Повторное сохранение того же `video_id` возвращает уже проиндексированный трек.

## yt-dlp

Для превью и сохранения нужен бинарник [yt-dlp](https://github.com/yt-dlp/yt-dlp).

### Разрешение бинарника (`YtdlpBinaryResolver`)

Порядок поиска:

1. Кэш в Application Support (`.wave_catcher/bin/`)
2. Бандл из `assets/bin/{linux,macos,windows}/` — копируется при первом запуске
3. Системный PATH / Homebrew (`yt-dlp`)

Подготовка бандла для разработки и релиза:

```bash
./scripts/fetch_ytdlp.sh
```

Альтернатива: `brew install yt-dlp` (macOS) или установка в PATH на Linux/Windows.

## YouTube Music API

`YtmInnerTubeRepository` — прямые запросы к InnerTube (как в Snowify), без официального YouTube Data API:

- `searchSongs` — поиск треков
- `searchSuggestions` — подсказки
- `getUpNexts` — похожие / Up Next
- `getArtistTopSongs` — топ треков исполнителя

Модель UI: `ExploreTrack` (`videoId`, `watchUrl`, `thumbnailUrl`, `title`, `artist`, `album`, `duration`, …).

## База данных

Таблица `import_sources` (миграция v3 в `library_database.dart`):

| Колонка | Описание |
|---------|----------|
| `video_id` | YouTube video ID (PK) |
| `file_path` | Абсолютный путь к сохранённому файлу (UNIQUE) |
| `saved_at_ms` | Время сохранения |

Репозиторий: `ImportSourceRepository` — всегда через актуальный `LibraryRepository`, не кэширует закрытое соединение SQLite.

## Файлы

| Файл | Назначение |
|------|------------|
| `lib/ui/screens/explore_screen.dart` | Экран раздела |
| `lib/ui/widgets/explore/explore_track_tile.dart` | Строка трека |
| `lib/ui/models/explore_track.dart` | Модель трека YouTube Music |
| `lib/ui/models/playable_item.dart` | `LocalPlayableItem` / `RemotePlayableItem` |
| `lib/ui/models/playback_mode.dart` | `library` / `explore` |
| `lib/services/explore_service.dart` | Поиск, рекомендации, `isAlreadySaved` |
| `lib/services/track_import_service.dart` | Сохранение в библиотеку |
| `lib/repositories/ytm_innertube_repository.dart` | InnerTube-клиент |
| `lib/repositories/ytdlp_repository.dart` | stream URL, download, кэш |
| `lib/repositories/ytdlp_binary_resolver.dart` | Поиск бинарника |
| `lib/repositories/import_source_repository.dart` | CRUD `import_sources` |
| `scripts/fetch_ytdlp.sh` | Загрузка standalone-бинарников в assets |

## Провайдеры

| Provider | Назначение |
|----------|------------|
| `exploreServiceProvider` | Поиск и рекомендации |
| `trackImportServiceProvider` | Сохранение трека |
| `ytmInnerTubeRepositoryProvider` | InnerTube-клиент |
| `ytdlpRepositoryProvider` | yt-dlp операции |
| `ytdlpAvailableProvider` | Доступность бинарника |
| `ytdlpVersionProvider` | Версия yt-dlp |

## Ограничения (MVP)

- Только поиск треков; альбомы и плейлисты YouTube Music не реализованы.
- Рекомендации: топ-3 исполнителя из библиотеки + Up Next; без Charts/Moods.
- Нет обогащения MusicBrainz при импорте.
- Нет codesign yt-dlp на macOS — при блокировке Gatekeeper использовать Homebrew или разрешить вручную.
- Превью требует сеть; локальная библиотека работает офлайн.

## Связанные документы

- [player.md](player.md) — очередь, `PlayableItem`, превью-поток
- [library-scanning.md](library-scanning.md) — `scanSingleFile`, схема БД
- [library-search.md](library-search.md) — локальный поиск (отдельно от Explore)
