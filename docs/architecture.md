# Архитектура

Десктопное приложение Music Player строится на простой и предсказуемой архитектуре.

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
    library_repository.dart
    library_database.dart
    metadata_override_repository.dart
    metadata_file_writer.dart
    entities/
  services/       # PlayerService, LibraryService, …
    settings_service.dart
    library_service.dart
    library_scanner_service.dart
    player_service.dart
    metadata/
      metadata_edit_service.dart
    scanner/        # фазы pipeline сканера
  ui/
    screens/      # экраны
    widgets/      # переиспользуемые виджеты
docs/             # документация (этот файл и др.)
```

## Модули данных (реализовано)

| Модуль | Слой | Назначение |
|--------|------|------------|
| `AppSettingsRepository` | Repository | путь к папке с музыкой (Application Support) |
| `LibraryRepository` | Repository | CRUD индекса в `library.db` |
| `SettingsService` | Service | выбор папки, проверка конфигурации |
| `LibraryScannerService` | Service | оркестрация сканирования |
| `LibraryService` | Service | чтение библиотеки для UI, глобальный поиск |
| `PlayerService` | Service | воспроизведение, очередь, repeat/shuffle |
| `MetadataOverrideRepository` | Repository | override-конфиг метаданных в `.music_player/` |
| `MetadataFileWriter` | Repository | запись тегов в аудиофайлы через `metadata_god` |
| `MetadataEditService` | Service | редактирование метаданных треков |

Подробности сканирования: [features/library-scanning.md](features/library-scanning.md).  
Подробности поиска: [features/library-search.md](features/library-search.md).  
Подробности плеера: [features/player.md](features/player.md).  
Редактирование метаданных: [features/metadata-editing.md](features/metadata-editing.md).

## Документация

Любое изменение архитектуры, добавление модуля или фичи сопровождается обновлением файлов в `docs/`.
