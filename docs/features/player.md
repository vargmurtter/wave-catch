# Воспроизведение (PlayerService)

Воспроизведение локальных аудиофайлов и превью-потоков из YouTube Music через [media_kit](https://pub.dev/packages/media_kit) (libmpv). UI плеера читает состояние из `playerUiStateProvider`, который делегирует в `PlayerService`.

## Форматы (локальная библиотека)

Поддерживаются те же расширения, что и при сканировании библиотеки:

`mp3`, `flac`, `m4a`, `aac`, `ogg`, `opus`, `wav`, `wma`

Источник списка: `kAudioExtensions` в `lib/services/scanner/scan_rules.dart`.

Превью из **Исследования** — HTTP-поток, URL получается через yt-dlp (см. [explore.md](explore.md)).

## Архитектура

```
UI (PlayerBar, QueuePanel, ExploreScreen, TrackListTile, …)
    ↓ playerUiStateProvider
PlayerService
    ↓                    ↓                    ↓
LibraryService      media_kit Player      YtdlpRepository (опц.)
    ↓
LibraryRepository
```

- **`PlayerService`** (`lib/services/player_service.dart`) — очередь, repeat/shuffle, локальные и remote-источники.
- **`playerServiceProvider`** — создаёт сервис, вызывает `dispose()` при уничтожении.
- **`PlayerUiStateNotifier`** — подписывается на `stateStream` сервиса, проксирует действия UI.

Инициализация: `MediaKit.ensureInitialized()` в `lib/main.dart`.

## Элементы очереди (`PlayableItem`)

Очередь и текущий трек описываются sealed-классом `PlayableItem`, а не только `Track`:

| Тип | Модель | `playbackMode` | Источник для media_kit |
|-----|--------|----------------|------------------------|
| `LocalPlayableItem` | `Track` | `library` | `file://` — путь к файлу |
| `RemotePlayableItem` | `ExploreTrack` | `explore` | HTTP URL от `YtdlpRepository.getStreamUrl` |

Обложка в плеере: локальные треки — `imagePath` (файл на диске); превью — `imageUrl` (thumbnail YouTube Music). Виджет `CoverArt` использует `Image.network` только для `http://` / `https://`.

## Состояние плеера (`PlayerUiState`)

| Поле | Описание |
|------|----------|
| `currentItem` | Текущий `PlayableItem` или `null` (плеер пустой) |
| `currentTrack` | `Track?` — только для локального элемента (удобный getter) |
| `playbackMode` | `library` / `explore` — из `currentItem` |
| `isExplorePlayback` | `true` при превью из Исследования |
| `queue` | Текущая очередь (`List<PlayableItem>`) |
| `queueIndex` | Индекс текущего элемента в очереди |
| `isPlaying` | Воспроизведение / пауза |
| `shuffleEnabled` | Случайный порядок |
| `repeatMode` | `off` / `all` / `one` |
| `volume` | 0.0–1.0 |
| `position`, `duration` | Прогресс (из media_kit) |
| `progress` | Вычисляемое: `position / duration` |
| `isQueueOpen` | Видимость панели очереди |

## Правила очереди (библиотека)

| Действие | Очередь | Старт |
|----------|---------|-------|
| Play альбом | Треки альбома (`track_number`, `title`) | С первого |
| Play трек в альбоме | Треки альбома | С выбранного |
| Play исполнитель | Все треки исполнителя (`title`) | С первого (или с выбранного) |
| «Играть всё» (главное) | Все треки библиотеки, **перемешаны** | С первого; `shuffleEnabled = true` |

При включённом shuffle до запуска альбома/исполнителя текущий стартовый трек остаётся первым, остальные перемешиваются.

## Очередь Explore

| Действие | Метод | Очередь |
|----------|-------|---------|
| Play в Исследовании | `playExploreTrack` | Один трек или список `ExploreTrack` |
| Сохранить из плеера | `TrackImportService` + `replaceCurrentExploreWithLocal` | Текущий remote-элемент заменяется на `LocalPlayableItem` |

Превью не сохраняется на диск автоматически.

## Repeat и shuffle

- **Repeat off** — после последнего трека остановка.
- **Repeat all** — после последнего → первый трек.
- **Repeat one** — зацикливание текущего трека.
- **Shuffle toggle** — перемешивает элементы **после** текущего; при выключении восстанавливает порядок из базовой очереди.

## Prev / Next

- **Next** — следующий элемент с учётом repeat; при `repeat one` — перемотка в начало.
- **Previous** — если проиграно > 3 с, перемотка в начало; иначе предыдущий трек (или последний при `repeat all` на первом).

## Точки запуска в UI

| Место | Метод |
|-------|-------|
| Hover play в `TrackListTile` (по умолчанию) | `playTrackInAlbum` |
| Hover play в `TrackListTile` на экране ПП | `playPlaylist` (с `startTrack`) |
| Кнопка Play на экране ПП | `playPlaylist` |
| Кнопка Play на альбоме | `playAlbum` |
| Кнопка Play на исполнителе / «Все треки» | `playArtist` |
| «Играть всё» на главном | `playAllShuffled` |
| Клик по треку в поиске | `playTrackInAlbum` |
| Кнопка Play в `TrackInfoPanel` | `playTrackInAlbum` |
| Play в `ExploreScreen` / `ExploreTrackTile` | `playExploreTrack` |
| Клик в `QueuePanel` | `jumpToIndex` |

## PlayerBar (Explore)

При `isExplorePlayback`:

- бейдж **«Превью»**;
- кнопка **«Сохранить в библиотеку»** (если yt-dlp доступен и трек ещё не сохранён);
- состояние **«В библиотеке»** для уже импортированных `video_id`.

## Зависимости

```yaml
media_kit: ^1.2.6
media_kit_libs_audio: ^1.0.7
```

Пакет `media_kit_libs_audio` подтягивает нативные libmpv-бинарники для macOS, Windows и Linux.

Превью дополнительно зависит от yt-dlp (см. [explore.md](explore.md)).

## Вне scope

- Пользовательские плейлисты (остаются mock)
- История «недавно проигранных»
- Системные медиа-клавиши / интеграция с ОС
- Автосохранение превью в библиотеку
