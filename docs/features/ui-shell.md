# UI-оболочка

Подробные дизайн-требования: [design-requirements.md](../design-requirements.md)

Десктопная UI-оболочка в стиле Spotify с красным акцентом. Библиотека и воспроизведение подключены через `LibraryService` и `PlayerService`.

> Этот документ описывает **текущую реализацию** оболочки. Нормативные требования для любой будущей вёрстки — в [design-requirements.md](../design-requirements.md).

## Layout

```
┌──────────┬─────────────────────────────────────┬──────────┐
│          │                              ┌──────┤ Track  │
│ Sidebar  │         Content Area         │Queue │ Info   │
│  240px   │  (раздел или детальный       │Panel │(overlay│
│          │   экран)                     │(опц.)│ опц.)  │
│          │                              │350px │ 350px  │
├──────────┴──────────────────────────────┴──────┴────────┤
│                      PlayerBar  96px                     │
└──────────────────────────────────────────────────────────┘
```

- **Сайдбар** — навигация: Главное, Исполнители, Альбомы, Плейлисты; поле глобального поиска
- **Контент** — экран выбранного раздела, детальный экран (исполнитель, альбом) или результаты поиска
- **Плеер** — закреплён снизу на всю ширину
- **Панель очереди** — выезжает справа при нажатии кнопки плейлиста в плеере
- **Панель трека** — плавающий overlay справа при клике по треку (не по play)

Детальные экраны: [library-detail-screens.md](library-detail-screens.md).

## Цветовая схема

| Токен | Значение | Назначение |
|-------|----------|------------|
| `background` | `#121212` | Фон контента |
| `sidebar` | `#000000` | Фон сайдбара |
| `surface` | `#181818` | Карточки, плеер |
| `surfaceElevated` | `#282828` | Hover, активные элементы |
| `accent` | `#FF4848` (RGB 255, 72, 72) | Акцент (вместо зелёного Spotify) |
| `sidebarOverlay` | `#D9000000` | Полупрозрачный сайдбар с blur |
| `playerOverlay` | `#D9181818` | Полупрозрачный плеер с blur |
| `textPrimary` | `#FFFFFF` | Основной текст |
| `textSecondary` | `#B3B3B3` | Вторичный текст |

Файлы темы: `lib/ui/theme/app_colors.dart`, `lib/ui/theme/app_theme.dart`.

## Структура виджетов

```
lib/ui/
  shell/
    app_shell.dart          # корневой layout
  screens/
    home_screen.dart            # 4 секции главного экрана
    artists_screen.dart         # сетка исполнителей
    albums_screen.dart          # сетка альбомов
    playlists_screen.dart       # список плейлистов
    artist_detail_screen.dart   # детальный экран исполнителя
    artist_tracks_screen.dart   # все треки исполнителя
    album_detail_screen.dart    # детальный экран альбома
    search_screen.dart          # результаты глобального поиска
  widgets/
    sidebar/                # AppSidebar, SidebarNavItem
    search/                 # GlobalSearchField, SearchResultTile
    player/                 # PlayerBar, VolumeControl, QueuePanel
    home/                   # карточки и секции
    track/                  # TrackListTile, TrackInfoPanel
    common/                 # CoverArt, DetailBackButton, FrostedPanel, PlayActionButton
  models/                   # Track, Album, Artist, LibraryRoute, …
  mock/
    mock_data.dart          # тестовые данные
```

## Провайдеры (Riverpod)

| Provider | Файл | Назначение |
|----------|------|------------|
| `selectedNavItemProvider` | `lib/di/providers.dart` | Активный пункт сайдбара |
| `playerUiStateProvider` | `lib/di/providers.dart` | Состояние плеера (прокси `PlayerService`) |
| `playerServiceProvider` | `lib/di/providers.dart` | Сервис воспроизведения |
| `homeSectionsProvider` | `lib/di/providers.dart` | Данные секций главного экрана |
| `libraryRouteProvider` | `lib/di/providers.dart` | Стек детальных маршрутов |
| `trackInfoPanelProvider` | `lib/di/providers.dart` | Плавающая панель информации о треке |
| `searchQueryProvider` | `lib/di/providers.dart` | Текст глобального поиска |
| `librarySearchResultsProvider` | `lib/di/providers.dart` | Результаты поиска по библиотеке |

Подробности поиска: [library-search.md](library-search.md).  
Подробности плеера: [player.md](player.md).

Кнопки плеера и точки запуска вызывают `PlayerUiStateNotifier` → `PlayerService`. Данные библиотеки — через `LibraryService`.

## Минимальный размер окна

900×640 px (через `window_manager` в `lib/main.dart`). Горизонтальные списки на главном экране имеют видимый `Scrollbar`.

## Скролл главного экрана

Область вертикального скролла без внешних отступов. Внутренние отступы (32 px) применяются к заголовкам и сеткам; горизонтальные списки прокручиваются на всю ширину с padding внутри `ListView`.

## Иконки

Используется пакет `lucide_icons_flutter`. Все иконки интерфейса — из набора Lucide.

## Что остаётся mock

- Плейлисты (`playlists_screen.dart`)
- Обложки без файла (градиентные placeholder'ы по `CoverArt`)
