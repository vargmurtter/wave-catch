# Детальные экраны библиотеки

Mock-экраны исполнителя, альбома и плавающая панель информации о треке. Данные из `MockData`, без сервисов и репозиториев.

Подробности оболочки: [ui-shell.md](ui-shell.md). Дизайн-требования: [design-requirements.md](../design-requirements.md).

## Экраны

### Исполнитель (`ArtistDetailScreen`)

Файл: `lib/ui/screens/artist_detail_screen.dart`

- Кнопка «Назад» + круглая обложка (200 px) + имя исполнителя
- Секция «Альбомы» — горизонтальный список `AlbumCard`
- Секция «Популярные треки» — до 5 треков (`TrackListTile`) + ссылка «Показать все»

### Все треки исполнителя (`ArtistTracksScreen`)

Файл: `lib/ui/screens/artist_tracks_screen.dart`

- Полный список треков исполнителя без группировки по альбомам
- В подписи строки отображается альбом

### Альбом (`AlbumDetailScreen`)

Файл: `lib/ui/screens/album_detail_screen.dart`

- Кнопка «Назад» + квадратная обложка (200 px) + название альбома
- Кликабельный исполнитель → экран исполнителя
- Год выхода
- Пронумерованный список треков
- Секция «Другие альбомы» — горизонтальный список альбомов того же исполнителя

## Навигация

Детальные экраны не добавляются в сайдбар. Используется стек маршрутов `libraryRouteProvider` (`List<LibraryRoute>`):

| Маршрут | Открытие |
|---------|----------|
| `LibraryMainRoute` | По умолчанию; сброс при смене пункта сайдбара |
| `ArtistDetailRoute` | Клик по `ArtistCard` |
| `ArtistTracksRoute` | «Показать все» на экране исполнителя |
| `AlbumDetailRoute` | Клик по `AlbumCard` или ссылке в панели трека |

Методы `LibraryRouteNotifier`: `openArtist`, `openArtistTracks`, `openAlbum`, `goBack`, `reset`.

`_ContentArea` в `app_shell.dart` рендерит экран по вершине стека.

## Панель информации о треке

Файл: `lib/ui/widgets/track/track_info_panel.dart`

Плавающее окно поверх контента, прижато к правому краю (над `PlayerBar`, 350 px). Не заменяет панель очереди — обе могут быть видны одновременно.

Состояние: `trackInfoPanelProvider` (`Track?`).

Открытие: клик по строке трека (`TrackListTile`, `RecentTrackTile`), не по кнопке play.

Содержимое:
- Обложка, название
- Альбом и исполнитель (кликабельные → детальные экраны)
- Год
- Метаданные: длительность, номер трека, жанр, формат, битрейт

## Виджет строки трека

Файл: `lib/ui/widgets/track/track_list_tile.dart`

- Клик по строке → `trackInfoPanelProvider.open(track)`
- Кнопка play при hover → `playTrackInAlbum(track)` — очередь = альбом, старт с выбранного трека
- Кнопка Play на заголовке альбома / исполнителя → `playAlbum` / `playArtist`
- Параметры: `showTrackNumber`, `showArtist`, `showAlbum`

## Mock-данные

Файл: `lib/ui/mock/mock_data.dart`

Расширенные модели:
- `Track`: `artistId`, `albumId`, `year`, `duration`, `trackNumber`, `genre`, `format`, `bitrate`
- `Album`: `artistId`, `year`

Хелперы: `artistById`, `albumById`, `trackById`, `albumsForArtist`, `tracksForAlbum`, `tracksForArtist`, `otherAlbumsByArtist`.

## Провайдеры

| Provider | Назначение |
|----------|------------|
| `libraryRouteProvider` | Стек детальных маршрутов |
| `trackInfoPanelProvider` | Открытый трек в плавающей панели |
