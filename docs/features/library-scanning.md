# Сканирование музыкальной библиотеки

Рекурсивное сканирование папки с музыкой, извлечение метаданных и обложек, сохранение индекса в SQLite.

## Хранилища

| Данные | Расположение |
|--------|--------------|
| Путь к папке с музыкой | `{ApplicationSupport}/.wave_catcher/app_config.json` |
| Стратегия группировки альбомов | `{ApplicationSupport}/.wave_catcher/app_config.json` |
| Индекс библиотеки | `{musicRoot}/.wave_catcher/library.db` |
| Связь YouTube → файл | таблица `import_sources` в `library.db` (схема v3) |
| Импорт из Explore | `{musicRoot}/Imports/{Artist}/{Title}.mp3` |
| Override-конфиг | `{musicRoot}/.wave_catcher/metadata_overrides.json` |
| Embedded-обложки | `{musicRoot}/.wave_catcher/covers/` |

## Первый запуск и настройки

- При первом запуске, если путь не сохранён, показывается `OnboardingScreen` с выбором папки через системный диалог (`file_picker`).
- Пункт **Настройки** в сайдбаре: текущий путь, смена папки, пересканирование, **группировка альбомов**.

## Группировка альбомов

Стратегия выбирается в **Настройки → Группировка альбомов** и сохраняется в `app_config.json` (`albumGroupingStrategy`). Смена стратегии требует **пересканирования** — состав альбомов в `library.db` пересчитывается заново.

| Стратегия | Ключ `albumId` | Когда использовать |
|-----------|----------------|-------------------|
| **По тегам (Album Artist)** — по умолчанию | `hash(groupingArtist \| albumTitle)` | Большинство библиотек с тегами. `groupingArtist` = `albumArtist` → исполнитель без `feat.` → исполнитель трека |
| **По папке на диске** | `hash(parentDir \| albumTitle)` | Музыка разложена по папкам `Artist/Album/` |
| **По названию альбома** | `hash(albumTitle)` или `hash(albumTitle \| year)` | Сборники, неоднородные теги. Может объединить разные релизы с одинаковым названием |

**Исполнитель альбома** (`albums.artist_id`) определяется при сборке альбома:
1. Наиболее частый тег `albumArtist` среди треков
2. Если все треки одного исполнителя — он
3. Иначе — «Разные исполнители»

**Исполнитель трека** (`tracks.artist_id`) всегда берётся из тега `artist` (с fallback на `albumArtist`, если `artist` пуст).

Модули: `album_grouping_strategy.dart`, `album_grouping.dart`, `entity_resolver.dart`, `cover_art_resolver.dart`.

## Правила сканирования

### Обход файлов

- Рекурсивный обход всех подпапок выбранной директории.
- Аудио: `mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`.
- Пропускаются каталог `.wave_catcher` и устаревшие `.covers`, `.music_player`, а также файл `library.db` в корне библиотеки.

### Метаданные

| Поле | Источник | Fallback |
|------|----------|----------|
| Название трека | теги файла | имя файла без расширения |
| Исполнитель трека | тег `artist` | тег `albumArtist`, затем «Неизвестный исполнитель» |
| Исполнитель альбома (тег) | тег `albumArtist` | — |
| Альбом | тег `album` | имя родительской папки, затем «Неизвестный альбом» |

### Обложки

Расширения изображений в файловой системе: `jpg`, `jpeg`, `png`, `webp`.

**Трек:**
1. Embedded cover из метаданных → кэш в `.wave_catcher/covers/{trackId}.ext`
2. Первое изображение в папке трека

**Альбом:**
1. Обложка любого трека альбома (embedded или из папки)
2. Первое изображение в папке любого трека альбома

### Кодировка тегов

Часть MP3-файлов (особенно старых русскоязычных) хранит теги в **Windows-1251**, но ID3 помечает их как **Latin-1**. В результате `metadata_god` отдаёт mojibake вида `Ôèëüòðóþùèé` вместо `Фильтрующий`.

При сканировании `TagTextFixer` пытается исправить такие строки: `latin1.encode` → `windows1251.decode`. Исправление применяется только к индексу в `library.db`; файлы на диске не изменяются.

Эвристика принимает результат, если в нём ≥ 2 кириллических буквы и доля кириллицы среди букв ≥ 30%. ASCII- и уже корректные кириллические строки не трогаются.

Чтобы применить исправление к уже проиндексированной библиотеке, выполните **Настройки → Пересканировать**.

### Идентификаторы

Детерминированные SHA-256 хеши:

- `artistId` — от нормализованного имени исполнителя **трека**
- `albumId` — зависит от выбранной стратегии группировки (см. раздел «Группировка альбомов»)
- `trackId` — от абсолютного пути файла

## Pipeline сканера

```
ScanJob → FileDiscovery → MetadataExtractor → TagTextFixer → EntityResolver
        → CoverArtResolver → LibraryPersister → .wave_catcher/library.db
```

Каталог: `lib/services/scanner/`

| Модуль | Ответственность |
|--------|-----------------|
| `file_discovery.dart` | рекурсивный обход, фильтр аудио |
| `metadata_extractor.dart` | чтение тегов через `metadata_god` |
| `tag_text_fixer.dart` | исправление CP1251-mojibake в текстовых полях |
| `entity_resolver.dart` | fallback-значения, stable ID, применение стратегии группировки |
| `album_grouping.dart` | расчёт `albumId` и исполнителя альбома |
| `album_grouping_strategy.dart` | enum стратегий, тексты для UI |
| `cover_art_resolver.dart` | обложки треков и альбомов |
| `library_persister.dart` | sync индекса в SQLite (`syncLibrary`) |
| `library_scanner_service.dart` | оркестратор, прогресс, `scanSingleFile` |

## Инкрементальная индексация одного файла

`LibraryScannerService.scanSingleFile` — полный pipeline сканера для одного пути (без полного rescan библиотеки). Используется при сохранении трека из **Исследования** (`TrackImportService`):

1. `open(musicRoot)` на `LibraryRepository`
2. извлечение метаданных, override, группировка альбома
3. `upsertTrack` в SQLite
4. после записи в `import_sources` — `LibraryService.refreshOverrides()`

Подробности импорта: [explore.md](explore.md).

## Пересканирование (rescan)

Полный rescan (**Настройки → Пересканировать**) синхронизирует индекс с диском, а не пересоздаёт базу с нуля.

`LibraryPersister` вызывает `LibraryRepository.syncLibrary`:

1. **Upsert** всех найденных `artists`, `albums`, `tracks` (как `scanSingleFile`).
2. **Удаление** из индекса треков, чьих `file_path` нет среди результатов сканирования.
3. **`deleteOrphanedArtistsAndAlbums()`** — очистка альбомов/исполнителей без треков (например, после смены стратегии группировки).
4. Очистка orphan-записей в `playlist_tracks` и `import_sources` для удалённых треков.

| Данные | Поведение при rescan |
|--------|----------------------|
| Файлы на диске | Перечитываются; метаданные и обложки обновляются |
| `trackId` | Стабилен, пока путь файла не менялся (`hash(filePath)`) |
| Плейлисты, «Избранное», «Сохранённые» | **Сохраняются** для треков, файлы которых на месте |
| Треки с удалёнными файлами | Убираются из индекса и из плейлистов |
| `import_sources` (Explore) | Orphan-записи для отсутствующих файлов удаляются |
| `indexed_at_ms` | Обновляется для всех просканированных треков |

При открытии `library.db` включён `PRAGMA foreign_keys = ON` — каскадное удаление связей плейлиста при удалении трека работает предсказуемо.

Папка `Imports/` (треки из Explore) сканируется наравне с остальной библиотекой.

## Слои

```
UI → LibraryService / LibraryScannerService / SettingsService
   → LibraryRepository / AppSettingsRepository
   → SQLite / файловая система
```

## Зависимости

- `file_picker` — выбор папки (macOS / Windows / Linux)
- `metadata_god` — чтение аудио-тегов
- `windows1251` — декодирование CP1251 при исправлении mojibake
- `sqlite3` + `sqlite3_flutter_libs` — SQLite на desktop
- `path_provider` — Application Support

## Настройка окружения (macOS)

`metadata_god` использует нативный Rust/XCFramework. После `flutter pub get` обязательно:

```bash
cd macos && pod install && cd ..
flutter run -d macos
```

Без `pod install` приложение падает с ошибкой `store_dart_post_cobject: symbol not found`.

Минимальная версия macOS: **12.0** (требование XCFramework metadata_god).

Для release-сборок в `macos/Runner/Configs/Release.xcconfig` отключена агрессивная strip-оптимизация, чтобы FFI-символы не удалялись линкером.

### App Sandbox

Приложение **не использует App Sandbox** — это desktop-плеер, которому нужен рекурсивный доступ к выбранной папке с музыкой и запись `.wave_catcher/library.db` в неё. Sandbox без security-scoped bookmarks блокирует диалог выбора папки и доступ к файлам после перезапуска.

## Вне scope

- Полный инкрементальный rescan по `file_modified_ms` (только точечный `scanSingleFile`)
- «Недавно проигранные»

Воспроизведение реализовано отдельно: [player.md](player.md).  
Импорт из YouTube Music: [explore.md](explore.md).
