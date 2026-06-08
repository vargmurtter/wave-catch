# Локализация интерфейса

Поддерживаются языки **English** (по умолчанию) и **Русский**.

## Первый запуск

При первом запуске показывается экран выбора языка (`LanguageSelectionScreen`). Выбор сохраняется в `app_config.json` (`languageCode`) и применяется ко всему интерфейсу.

Далее — стандартный онбординг (выбор папки с музыкой), если библиотека ещё не настроена.

## Настройки

Язык можно изменить в **Настройки → Язык**. Переключение применяется сразу, без перезапуска приложения.

## Реализация

| Компонент | Назначение |
|-----------|------------|
| `lib/l10n/app_en.arb`, `app_ru.arb` | строки интерфейса |
| `lib/l10n/app_localizations.dart` | сгенерированный API (`flutter gen-l10n`) |
| `lib/l10n/app_locale.dart` | коды языков и `Locale` |
| `lib/l10n/l10n_extensions.dart` | локализованные подписи enum-ов настроек |
| `AppSettingsRepository` | хранение `languageCode` |
| `AppSettingsState.language` | текущий язык для `MaterialApp.locale` |

Строки в UI берутся через `AppLocalizations.of(context)`. Сервисный слой использует коды ошибок (`MetadataEditErrorCode`), сообщения формируются в UI.

## Добавление строки

1. Добавить ключ в `app_en.arb` и перевод в `app_ru.arb`.
2. Выполнить `flutter gen-l10n` (или `flutter pub get`, если включён `generate: true`).
3. Использовать `l10n.myKey` в виджете.
