# Воспроизведение (PlayerService)

Реальное воспроизведение аудиофайлов через [media_kit](https://pub.dev/packages/media_kit) (libmpv). UI плеера читает состояние из `playerUiStateProvider`, который делегирует в `PlayerService`.

## Форматы

Поддерживаются те же расширения, что и при сканировании библиотеки:

`mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`

Источник списка: `kAudioExtensions` в `lib/services/scanner/scan_rules.dart`.

## Архитектура

```
UI (PlayerBar, TrackListTile, экраны)
    ↓ playerUiStateProvider
PlayerService
    ↓                    ↓
LibraryService      media_kit Player
    ↓
LibraryRepository
```

- **`PlayerService`** (`lib/services/player_service.dart`) — очередь, repeat/shuffle, управление движком.
- **`playerServiceProvider`** — создаёт сервис, вызывает `dispose()` при уничтожении.
- **`PlayerUiStateNotifier`** — подписывается на `stateStream` сервиса, проксирует действия UI.

Инициализация: `MediaKit.ensureInitialized()` в `lib/main.dart`.

## Состояние плеера (`PlayerUiState`)

| Поле | Описание |
|------|----------|
| `currentTrack` | Текущий трек или `null` (плеер пустой) |
| `queue` | Текущий плейлист воспроизведения |
| `queueIndex` | Индекс текущего трека в очереди |
| `isPlaying` | Воспроизведение / пауза |
| `shuffleEnabled` | Случайный порядок |
| `repeatMode` | `off` / `all` / `one` |
| `volume` | 0.0–1.0 |
| `position`, `duration` | Прогресс (из media_kit) |
| `progress` | Вычисляемое: `position / duration` |
| `isQueueOpen` | Видимость панели очереди |

## Правила очереди

| Действие | Очередь | Старт |
|----------|---------|-------|
| Play альбом | Треки альбома (`track_number`, `title`) | С первого |
| Play трек в альбоме | Треки альбома | С выбранного |
| Play исполнитель | Все треки исполнителя (`title`) | С первого (или с выбранного) |
| «Играть всё» (главное) | Все треки библиотеки, **перемешаны** | С первого; `shuffleEnabled = true` |

При включённом shuffle до запуска альбома/исполнителя текущий стартовый трек остаётся первым, остальные перемешиваются.

## Repeat и shuffle

- **Repeat off** — после последнего трека остановка.
- **Repeat all** — после последнего → первый трек.
- **Repeat one** — зацикливание текущего трека.
- **Shuffle toggle** — перемешивает треки **после** текущего; при выключении восстанавливает порядок из базовой очереди.

## Prev / Next

- **Next** — следующий трек с учётом repeat; при `repeat one` — перемотка в начало.
- **Previous** — если проиграно > 3 с, перемотка в начало; иначе предыдущий трек (или последний при `repeat all` на первом треке).

## Точки запуска в UI

| Место | Метод |
|-------|-------|
| Hover play в `TrackListTile` | `playTrackInAlbum` |
| Кнопка Play на альбоме | `playAlbum` |
| Кнопка Play на исполнителе / «Все треки» | `playArtist` |
| «Играть всё» на главном | `playAllShuffled` |
| Клик по треку в поиске | `playTrackInAlbum` |
| Кнопка Play в `TrackInfoPanel` | `playTrackInAlbum` |
| Клик в `QueuePanel` | `jumpToIndex` |

## Зависимости

```yaml
media_kit: ^1.2.6
media_kit_libs_audio: ^1.0.7
```

Пакет `media_kit_libs_audio` подтягивает нативные libmpv-бинарники для macOS, Windows и Linux.

## Вне scope

- Пользовательские плейлисты (остаются mock)
- История «недавно проигранных»
- Системные медиа-клавиши / интеграция с ОС
