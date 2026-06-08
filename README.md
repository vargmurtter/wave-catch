# Wave Catch

**A local-first desktop music player for your own library.**

Wave Catch is a cross-platform desktop app for organizing and listening to music that lives on your machine. No accounts, no uploads, no streaming dependency — your files stay where you put them, and the player works with them directly.

> **Early development.** Features and APIs are evolving. Expect rough edges.

---

## Why local-first?

| Principle | What it means in Wave Catch |
|-----------|----------------------------|
| **Your files, your disk** | Music is read from folders you choose. Nothing is uploaded to a cloud service. |
| **Index beside the library** | A SQLite index (`.wave_catcher/library.db`) is stored next to your music, not on a remote server. |
| **Metadata stays local** | Tag edits are written back to audio files. Overrides live in `.wave_catcher/` under your library root. |
| **Offline by default** | Playback, browsing, and search work without a network connection. |
| **Network is optional** | Artist bios and artwork can be fetched from public APIs (MusicBrainz, Wikipedia) and cached on disk — only when you ask for them. |

Wave Catch is built for people who own their collection and want a player that respects that.

---

## Features

- **Library scanning** — recursive scan of local folders; metadata and embedded artwork extraction
- **Browse & search** — artists, albums, tracks; global search across the library
- **Playback** — queue, shuffle, repeat; formats include MP3, FLAC, M4A, AAC, OGG, Opus, WAV, WMA
- **Metadata editing** — edit tags and write changes to files
- **Artist info** — optional enrichment from MusicBrainz / Wikipedia with on-disk cache
- **Album grouping strategies** — by album artist tags, folder layout, or album title
- **Localization** — English and Russian UI
- **Desktop-native UI** — sidebar navigation, player bar, queue panel

See [`docs/`](docs/) for architecture and feature details.

---

## AI-assisted development

This project is **AI-assisted**: significant parts of the codebase, documentation, and iteration workflow were created and refined with help from AI coding tools (e.g. Cursor). Human direction, review, and architectural decisions remain central; AI is used to accelerate implementation and exploration, not to replace judgment about product and design.

---

## Supported platforms

| Platform | Status |
|----------|--------|
| macOS | supported |
| Linux | supported |
| Windows | supported |

Built with [Flutter](https://flutter.dev/) and Dart.

---

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.9.2`)
- Desktop toolchain for your target OS: [macOS](https://docs.flutter.dev/platform-integration/macos/setup) · [Linux](https://docs.flutter.dev/platform-integration/linux/setup) · [Windows](https://docs.flutter.dev/platform-integration/windows/setup)

Verify your environment:

```bash
flutter doctor
```

---

## Quick start

**1. Clone and enter the project**

```bash
git clone <repository-url>
cd music_player
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Run**

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

On first launch, choose the folder that contains your music. The app will scan it and build a local index.

---

## Release builds

```bash
flutter build macos    # macOS
flutter build linux    # Linux
flutter build windows  # Windows
```

---

## Project layout

```
lib/            Application source (UI, services, repositories)
docs/           Architecture and feature documentation
macos/          macOS runner
linux/          Linux runner
windows/        Windows runner
```

Layering: **UI → Services → Repositories → local files & SQLite**. Dependencies are wired through [Riverpod](https://riverpod.dev/). Details: [`docs/architecture.md`](docs/architecture.md).

---

## Documentation

| Topic | Document |
|-------|----------|
| Architecture | [`docs/architecture.md`](docs/architecture.md) |
| Library scanning | [`docs/features/library-scanning.md`](docs/features/library-scanning.md) |
| Player | [`docs/features/player.md`](docs/features/player.md) |
| Search | [`docs/features/library-search.md`](docs/features/library-search.md) |
| Metadata editing | [`docs/features/metadata-editing.md`](docs/features/metadata-editing.md) |
| Artist info | [`docs/features/artist-info.md`](docs/features/artist-info.md) |
| Localization | [`docs/features/localization.md`](docs/features/localization.md) |

---

## License

[MIT](LICENSE) — use, fork, and modify freely. Pull requests are not accepted; maintain your own fork if you want changes.
