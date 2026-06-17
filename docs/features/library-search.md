# Глобальный поиск по библиотеке

Поиск одновременно по исполнителям, альбомам и трекам **локальной библиотеки**. Результаты отображаются в контентной области при вводе запроса в поле в сайдбаре.

> Поиск YouTube Music — отдельно, в разделе **«Исследование»** ([explore.md](explore.md)). Глобальное поле в сайдбаре к сети не обращается.

## UX

- Поле **«Поиск»** — в сайдбаре под заголовком «Wave Catch», всегда доступно.
- При непустом запросе (`trim`) контентная область показывает `SearchScreen` вместо текущего экрана или детального маршрута.
- Результаты сгруппированы в три секции: **Исполнители**, **Альбомы**, **Треки**. Пустые секции скрываются.
- Debounce запроса: **200 ms**. Пока debounce не сработал, показывается «Поиск…».
- Лимит: **20 результатов** на категорию.

### Действия при выборе

| Тип | Действие |
|-----|----------|
| Исполнитель | Сброс маршрута → экран исполнителя |
| Альбом | Сброс маршрута → экран альбома |
| Трек | Сброс поиска → `playTrackInAlbum(track)` (очередь = альбом) |

После выбора запрос очищается.

## Слои

```
GlobalSearchField / SearchScreen (UI)
    ↓
searchQueryProvider, librarySearchResultsProvider (Riverpod)
    ↓
LibraryService.search()
    ↓
LibraryRepository.searchArtists / searchAlbums / searchTracks
    ↓
Фильтрация в памяти через Dart toLowerCase() (Unicode)
```

## Поисковые запросы

| Категория | Поля |
|-----------|------|
| Исполнители | `artists.name` |
| Альбомы | `albums.title`, `artists.name` |
| Треки | `tracks.title`, `artists.name`, `albums.title` |

Спецсимволы `%` и `_` в пользовательском вводе удаляются. Сравнение регистронезависимое: `toLowerCase()` в Dart (поддерживает кириллицу и Latin).

## Файлы

| Файл | Назначение |
|------|------------|
| `lib/repositories/library_repository.dart` | SQL-поиск |
| `lib/services/library_service.dart` | `search()`, маппинг в UI-модели |
| `lib/ui/models/library_search_results.dart` | Модель результатов |
| `lib/ui/widgets/search/global_search_field.dart` | Поле ввода в сайдбаре |
| `lib/ui/widgets/search/search_result_tile.dart` | Строка результата |
| `lib/ui/screens/search_screen.dart` | Экран результатов и навигация |
| `lib/di/providers.dart` | `searchQueryProvider`, `debouncedSearchQueryProvider`, `librarySearchResultsProvider` |

## Провайдеры

| Provider | Назначение |
|----------|------------|
| `searchQueryProvider` | Текущий текст запроса (мгновенно) |
| `debouncedSearchQueryProvider` | Запрос после debounce 200 ms |
| `librarySearchResultsProvider` | Результаты по debounced-запросу |

После rescan библиотеки результаты обновляются через `libraryRefreshProvider`.

## Ограничения

- FTS5 и ранжирование не реализованы — фильтрация в памяти достаточна для локальной библиотеки.
- Горячая клавиша поиска не добавлена.
- Отдельного пункта «Поиск» в навигации нет.
