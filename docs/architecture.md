# Архитектура

Десктопное приложение Wave Catch строится на простой и предсказуемой архитектуре.

## Принципы

| Принцип | Описание |
|---------|----------|
| **Repository** | Единственная точка входа/выхода для данных |
| **Service** | Вся бизнес-логика живёт в сервисах |
| **DI** | Все зависимости внедряются явно, без скрытого создания объектов |
| **KISS** | Простота важнее «умных» абстракций |

## Слои

```
UI (виджеты, экраны)
    ↓
Services (бизнес-логика)
    ↓
Repositories (данные)
    ↓
Источники (файловая система, БД, …)
```

### Репозитории

- Отвечают только за чтение и запись данных.
- Скрывают детали хранения от остального приложения.
- Не содержат бизнес-правил.

### Сервисы

- Реализуют сценарии использования: воспроизведение, поиск, управление плейлистами и т.д.
- Могут вызывать несколько репозиториев и других сервисов.
- Не знают о виджетах и навигации.

### UI

- Отображает состояние и передаёт действия пользователя в сервисы.
- Не обращается к репозиториям и файловой системе напрямую.

## Dependency Injection

Для DI используется [Riverpod](https://riverpod.dev/) (`flutter_riverpod`).

- Точка входа: `ProviderScope` в `lib/main.dart`.
- Регистрация провайдеров: `lib/di/providers.dart`.
- Зависимости в сервисах и репозиториях передаются через конструкторы.

Связывать через DI нужно:

- сервис с репозиторием;
- сервис с сервисом;
- UI с сервисом.

Прямое создание зависимостей внутри классов (`Repository()` в теле сервиса) запрещено.

## KISS

- Не вводите лишние интерфейсы, если есть одна реализация и нет планов на подмену.
- Не усложняйте код ради «правильной» архитектуры — достаточно трёх слоёв выше.
- Рефакторинг — когда появилась реальная потребность, а не заранее.

## Структура каталогов

```
lib/
  main.dart       # точка входа, ProviderScope
  app.dart        # корневой виджет приложения
  di/
    providers.dart  # Riverpod-провайдеры
  repositories/   # MusicRepository, PlaylistRepository, …
    app_settings_repository.dart
    artist_info_cache_repository.dart
    musicbrainz_api_repository.dart
    wikipedia_api_repository.dart
    lastfm_api_repository.dart
    library_repository.dart
    library_database.dart
    import_source_repository.dart
    metadata_override_repository.dart
    metadata_file_writer.dart
    ytm_innertube_repository.dart
    ytdlp_repository.dart
    ytdlp_binary_resolver.dart
    entities/
  services/       # PlayerService, LibraryService, …
    artist_info_service.dart
    settings_service.dart
    library_service.dart
    library_scanner_service.dart
    player_service.dart
    explore_service.dart
    track_import_service.dart
    metadata/
      metadata_edit_service.dart
    scanner/        # фазы pipeline сканера
  l10n/           # локализация (ARB, AppLocalizations)
  ui/
    screens/      # экраны
    widgets/      # переиспользуемые виджеты
docs/             # документация (этот файл и др.)
```

## Модули данных (реализовано)

| Модуль | Слой | Назначение |
|--------|------|------------|
| `AppSettingsRepository` | Repository | путь к папке с музыкой, язык интерфейса (Application Support) |
| `LibraryRepository` | Repository | CRUD индекса в `.wave_catcher/library.db` |
| `SettingsService` | Service | выбор папки, проверка конфигурации |
| `LibraryScannerService` | Service | оркестрация сканирования |
| `LibraryService` | Service | чтение библиотеки для UI, глобальный поиск |
| `PlayerService` | Service | воспроизведение, очередь, repeat/shuffle |
| `MetadataOverrideRepository` | Repository | override-конфиг метаданных в `.wave_catcher/` |
| `MetadataFileWriter` | Repository | запись тегов в аудиофайлы через `metadata_god` |
| `MetadataEditService` | Service | редактирование метаданных треков |
| `MusicBrainzApiRepository` | Repository | поиск исполнителя, ссылки Wikipedia/Wikidata |
| `WikipediaApiRepository` | Repository | описание и изображение из Wikipedia/Wikidata |
| `ArtistInfoCacheRepository` | Repository | кэш данных исполнителей на диске |
| `ArtistInfoService` | Service | загрузка и кэширование информации об исполнителе |
| `LastFmApiRepository` | Repository | *(неактивно)* HTTP-запросы к Last.fm API |
| `YtmInnerTubeRepository` | Repository | YouTube Music: поиск, подсказки, Up Next, топ артиста (InnerTube) |
| `YtdlpRepository` | Repository | stream URL и скачивание аудио через yt-dlp |
| `YtdlpBinaryResolver` | Repository | поиск бинарника: bundle (in-place) → Linux fallback → PATH |
| `ImportSourceRepository` | Repository | связь `video_id` ↔ локальный файл (`import_sources`) |
| `ExploreService` | Service | поиск и рекомендации в разделе «Исследование» |
| `TrackImportService` | Service | сохранение трека из Explore в `{musicRoot}/Imports/` |

Подробности сканирования: [features/library-scanning.md](features/library-scanning.md).  
Подробности поиска: [features/library-search.md](features/library-search.md).  
Раздел «Исследование»: [features/explore.md](features/explore.md).  
Подробности плеера: [features/player.md](features/player.md).  
Редактирование метаданных: [features/metadata-editing.md](features/metadata-editing.md).  
Информация об исполнителе: [features/artist-info.md](features/artist-info.md).  
Локализация: [features/localization.md](features/localization.md).

## Документация

Любое изменение архитектуры, добавление модуля или фичи сопровождается обновлением файлов в `docs/`.
