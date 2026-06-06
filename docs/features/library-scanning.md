# Сканирование музыкальной библиотеки

Рекурсивное сканирование папки с музыкой, извлечение метаданных и обложек, сохранение индекса в SQLite.

## Хранилища

| Данные | Расположение |
|--------|--------------|
| Путь к папке с музыкой | `{ApplicationSupport}/music_player/app_config.json` |
| Индекс библиотеки | `{musicRoot}/library.db` |
| Embedded-обложки | `{musicRoot}/.covers/` |

## Первый запуск и настройки

- При первом запуске, если путь не сохранён, показывается `OnboardingScreen` с выбором папки через системный диалог (`file_picker`).
- Пункт **Настройки** в сайдбаре: текущий путь, смена папки, пересканирование.

## Правила сканирования

### Обход файлов

- Рекурсивный обход всех подпапок выбранной директории.
- Аудио: `mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`.
- Пропускаются `library.db` и каталог `.covers`.

### Метаданные

| Поле | Источник | Fallback |
|------|----------|----------|
| Название трека | теги файла | имя файла без расширения |
| Исполнитель | теги | «Неизвестный исполнитель» |
| Альбом | теги | «Неизвестный альбом» |

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

- `artistId` — от нормализованного имени исполнителя
- `albumId` — от `artist|album`
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
| `entity_resolver.dart` | fallback-значения, stable ID |
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
