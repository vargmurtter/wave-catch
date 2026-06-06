# waveCatcher

Десктопное приложение для организации и прослушивания музыки.

## Описание

waveCatcher — кроссплатформенный музыкальный плеер с удобным интерфейсом для управления локальной музыкальной библиотекой. Приложение позволяет собирать коллекцию треков, упорядочивать их и слушать без браузера и сторонних сервисов.

## Возможности

- Организация музыкальной библиотеки
- Воспроизведение аудиофайлов
- Десктопный интерфейс, адаптированный для повседневного использования

> Проект находится на ранней стадии разработки. Функциональность будет расширяться по мере работы над приложением.

## Технологии

- [Flutter](https://flutter.dev/) — UI и логика приложения
- Dart

## Поддерживаемые платформы

- macOS
- Linux
- Windows

## Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.9.2)
- Настроенная среда для десктопной разработки на Flutter ([macOS](https://docs.flutter.dev/platform-integration/macos/setup) / [Linux](https://docs.flutter.dev/platform-integration/linux/setup) / [Windows](https://docs.flutter.dev/platform-integration/windows/setup))

Проверьте готовность окружения:

```bash
flutter doctor
```

## Установка и запуск

1. Клонируйте репозиторий и перейдите в каталог проекта:

```bash
git clone <url-репозитория>
cd music_player
```

2. Установите зависимости:

```bash
flutter pub get
```

3. Запустите приложение на нужной платформе:

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## Сборка релиза

```bash
# macOS
flutter build macos

# Linux
flutter build linux

# Windows
flutter build windows
```

## Структура проекта

```
lib/          — исходный код приложения
macos/        — нативная оболочка для macOS
linux/        — нативная оболочка для Linux
windows/      — нативная оболочка для Windows
```

## Лицензия

Лицензия не указана.
