# Сканирование музыкальной библиотеки

Рекурсивное сканирование папки с музыкой, извлечение метаданных и обложек, сохранение индекса в SQLite.

## Хранилища

| Данные | Расположение |
|--------|--------------|
| Путь к папке с музыкой | `{ApplicationSupport}/music_player/app_config.json` |
| Стратегия группировки альбомов | `{ApplicationSupport}/music_player/app_config.json` |
| Индекс библиотеки | `{musicRoot}/library.db` |
| Embedded-обложки | `{musicRoot}/.covers/` |

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
- Пропускаются `library.db` и каталог `.covers`.

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
1. Embedded cover из метаданных → кэш в `.covers/{trackId}.ext`
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
        → CoverArtResolver → LibraryPersister → library.db
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
| `library_persister.dart` | запись в SQLite |
| `library_scanner_service.dart` | оркестратор, прогресс |

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

Приложение **не использует App Sandbox** — это desktop-плеер, которому нужен рекурсивный доступ к выбранной папке с музыкой и запись `library.db` в неё. Sandbox без security-scoped bookmarks блокирует диалог выбора папки и доступ к файлам после перезапуска.

## Вне scope

- Плейлисты (остаются на моках)
- Инкрементальный scan по `file_modified_ms`
- «Недавно проигранные» / избранное

Воспроизведение реализовано отдельно: [player.md](player.md).
