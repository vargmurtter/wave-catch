# Дизайн-требования

Нормативный документ для вёрстки UI Music Player. При любой новой верстке или правке интерфейса сверяйтесь с этим файлом.

Текущая реализация оболочки описана отдельно: [features/ui-shell.md](features/ui-shell.md).

## Концепция

- **Платформа:** десктопное приложение (macOS, Windows, Linux).
- **Референс:** Spotify — layout, плотность, тёмная тема, горизонтальные секции с карточками.
- **Отличие от Spotify:** акцентный цвет — красный, не зелёный.
- **Состояние UI:** визуальные решения не зависят от наличия реальных данных; mock-допустим, но вёрстка должна быть production-ready.

## Цветовая палитра

Все цвета — через `AppColors` в `lib/ui/theme/app_colors.dart`. Не хардкодить hex в виджетах.

| Токен | Значение | Назначение |
|-------|----------|------------|
| `background` | `#121212` | Фон контентной области |
| `sidebar` | `#000000` | Базовый цвет сайдбара |
| `surface` | `#181818` | Карточки, фоны элементов |
| `surfaceElevated` | `#282828` | Hover, выделение |
| `accent` | `#FF4848` (RGB 255, 72, 72) | Акцент: активные иконки, кнопка play, прогресс |
| `sidebarOverlay` | `#D9000000` | Сайдбар с blur |
| `surfaceOverlay` | `#CC181818` | Всплывающие панели с blur |
| `playerOverlay` | `#D9181818` | Плеер с blur |
| `queueOverlay` | `#E6181818` | Панель очереди с blur |
| `textPrimary` | `#FFFFFF` | Заголовки, названия |
| `textSecondary` | `#B3B3B3` | Исполнители, подписи |
| `divider` | `#3E3E3E` | Разделители, границы панелей |
| `hover` | `#33FFFFFF` | Подсветка hover (полупрозрачный белый) |

Тема: `AppTheme.dark` в `lib/ui/theme/app_theme.dart`.

## Типографика

| Элемент | Стиль | Размер / вес |
|---------|-------|--------------|
| Заголовок экрана | `headlineMedium` | 24px, w700 |
| Заголовок секции | `titleLarge` | 20px, w700 |
| Название карточки / трека | custom | 14px, w600 |
| Исполнитель / подпись | `bodyMedium` / custom | 13–14px, w400, `textSecondary` |
| Мелкий текст | `bodySmall` | 12px |

## Layout оболочки

Три зоны, плеер всегда виден:

```
┌──────────┬─────────────────────────────────────┬──────────┐
│ Sidebar  │         Content Area                │  Queue   │
│  240px   │         (активный экран)            │ (опц.)   │
│          │                                     │  350px   │
├──────────┴─────────────────────────────────────┴──────────┤
│                      PlayerBar  96px                      │
└───────────────────────────────────────────────────────────┘
```

| Зона | Ширина / высота | Поведение |
|------|-----------------|-----------|
| Сайдбар | 240px | Фиксированная ширина, навигация |
| Контент | `Expanded` | Вертикальный скролл, смена экранов |
| Панель очереди | 350px | Появляется справа по кнопке в плеере |
| Плеер | 96px высота | На всю ширину, поверх контента не заходит |

Корневой виджет: `AppShell` (`lib/ui/shell/app_shell.dart`).

## Навигация (сайдбар)

Четыре пункта, Lucide-иконки:

| Пункт | Иконка |
|-------|--------|
| Главное | `LucideIcons.house` |
| Исполнители | `LucideIcons.users` |
| Альбомы | `LucideIcons.disc3` |
| Плейлисты | `LucideIcons.listMusic` |

Состояния:
- **Активный:** красная иконка, жирный текст, фон `surfaceElevated` с прозрачностью.
- **Hover:** лёгкая подсветка (`AppColors.hover`), `MouseRegion` + `SystemMouseCursors.click`.

## Главный экран

Четыре секции, каждая — заголовок + горизонтальный скролл карточек:

1. Последнее прослушанное — компактные карточки треков (`RecentTrackTile`)
2. Последнее добавленное — `AlbumCard`
3. Любимые альбомы — `AlbumCard`
4. Любимые исполнители — `ArtistCard` (круглые аватары)

## Плеер (PlayerBar)

Три колонки, как у Spotify:

**Левая:** обложка 56px + название трека + исполнитель.

**Центр:** shuffle · prev · play/pause · next · repeat.

**Правая:** кнопка очереди (`listMusic`) · громкость (popup-слайдер).

Дополнительно:
- Полоска прогресса 2px над контролами, цвет `accent`.
- Shuffle / repeat подсвечиваются `accent` в активном состоянии.
- Repeat: цикл off → all → one (`repeat` / `repeat1`).
- Кнопка play — красный круглый фон (`accent`).

## Визуальные эффекты (blur и прозрачность)

Использовать виджет `FrostedPanel` (`lib/ui/widgets/common/frosted_panel.dart`):
- `BackdropFilter` + полупрозрачный `color` из overlay-токенов.
- Применять к: сайдбар, плеер, панель очереди, popup громкости.

**Это не glassmorphism:** без стеклянных рамок, бликов, градиентных border. Только мягкий blur и приглушённая прозрачность.

Hover на карточках: лёгкий `AnimatedScale` (1.03) и тень — **только в горизонтальных списках**, не в сетках.

## Иконки

- Пакет: `lucide_icons_flutter`.
- Все иконки интерфейса — Lucide. Material Icons не использовать (кроме внутренних механизмов Flutter).

## Скролл и отступы

### Вертикальный скролл экрана

- `SingleChildScrollView` / `ScreenScrollView` — **без внешних padding**.
- Внутренние отступы — только у контента внутри:
  - заголовок экрана: `top 24`, горизонтально `32`;
  - заголовки секций и сетки: горизонтально `32`;
  - нижний отступ списка: `32`.

### Горизонтальные списки

- Секция: `ContentSection(fullBleedChild: true)` — заголовок с padding, список на всю ширину.
- Padding горизонтальный — внутри `ListView` (`horizontalPadding: 32`).
- Обязателен видимый `Scrollbar` (`thumbVisibility: true`, `interactive: true`).

## Адаптивность и окно

- **Минимальный размер окна:** 900×640 px (`window_manager` в `lib/main.dart`).
- Карточки в сетках: `LayoutBuilder`, размер обложки = ширина ячейки.
- Сетки: `SliverGridDelegateWithMaxCrossAxisExtent` + `mainAxisExtent` (не `childAspectRatio`).
  - Альбомы: `mainAxisExtent: 250`
  - Исполнители: `mainAxisExtent: 220`
- В сетках: `enableHoverScale: false` на `AlbumCard` / `ArtistCard` — избегать overflow.

## Паттерны кода

| Задача | Виджет / файл |
|--------|---------------|
| Экран со скроллом | `ScreenScrollView` |
| Секция с full-bleed списком | `ContentSection(fullBleedChild: true)` |
| Горизонтальный список | `HorizontalCardList` |
| Placeholder обложки | `CoverArt` (градиент по `seed`) |
| Blur-панель | `FrostedPanel` |
| Цвета и тема | `AppColors`, `AppTheme` |

Структура каталогов: `lib/ui/screens/`, `lib/ui/widgets/`, `lib/ui/theme/`, `lib/ui/shell/`.

## Антипаттерны

| Нельзя | Почему | Как правильно |
|--------|--------|---------------|
| `Padding` вокруг `SingleChildScrollView` | Контент «исчезает в пустоту» при скролле | Padding внутри child, `ScreenScrollView` |
| Фиксированная обложка 160px в сетке | `bottom overflowed` | `LayoutBuilder`, обложка = ширина ячейки |
| `childAspectRatio` без учёта текста | Overflow под обложкой | `mainAxisExtent` с запасом под 2 строки текста |
| `AnimatedScale` в GridView | Масштаб выходит за ячейку | `enableHoverScale: false` |
| Material Icons в UI | Нарушение дизайн-системы | Lucide Icons |
| Непрозрачный фон у сайдбара/плеера | Разрыв с установленным стилем | `FrostedPanel` + overlay-токены |
| Glassmorphism (рамки, блики) | Явный запрет пользователя | Только blur + opacity |
| Хардкод цветов в виджетах | Рассинхрон с темой | `AppColors.*` |
| Горизонтальный список без Scrollbar | Контент скрывается при узком окне | `Scrollbar` + min window size |

## Примеры

### Скролл экрана

```dart
// ❌ Плохо — внешний padding у scroll area
Padding(
  padding: EdgeInsets.all(32),
  child: SingleChildScrollView(...),
)

// ✅ Хорошо — нулевые отступы у scroll, padding у контента
ScreenScrollView(
  child: Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: 24),
        child: ScreenHeader(title: 'Главное'),
      ),
      ContentSection(
        title: 'Любимые альбомы',
        fullBleedChild: true,
        child: HorizontalCardList(...),
      ),
    ],
  ),
)
```

### Карточка в сетке

```dart
// ❌ Плохо — фиксированный размер, hover-scale
AlbumCard(album: album)

// ✅ Хорошо — адаптивная вёрстка, без scale
AlbumCard(album: album, enableHoverScale: false)
```

### Панель с blur

```dart
// ❌ Плохо — непрозрачный Container
Container(color: AppColors.surface, child: player)

// ✅ Хорошо
FrostedPanel(
  color: AppColors.playerOverlay,
  blurSigma: 24,
  border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
  child: player,
)
```
