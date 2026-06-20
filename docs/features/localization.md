# UI localization

Supported languages: **English** (default) and **Russian**.

## First launch

On first launch, a language selection screen is shown (`LanguageSelectionScreen`). The choice is saved in `app_config.json` (`languageCode`) and applied to the entire UI.

Next — standard onboarding (music folder selection) if the library is not yet configured.

## Settings

Language can be changed in **Settings → Language**. Switching applies immediately, without restarting the app.

## Implementation

| Component | Purpose |
|-----------|---------|
| `lib/l10n/app_en.arb`, `app_ru.arb` | UI strings |
| `lib/l10n/app_localizations.dart` | generated API (`flutter gen-l10n`) |
| `lib/l10n/app_locale.dart` | language codes and `Locale` |
| `lib/l10n/l10n_extensions.dart` | localized settings enum labels |
| `AppSettingsRepository` | stores `languageCode` |
| `AppSettingsState.language` | current language for `MaterialApp.locale` |

UI strings come from `AppLocalizations.of(context)`. The service layer uses error codes (`MetadataEditErrorCode`); messages are formed in the UI.

## Adding a string

1. Add a key to `app_en.arb` and a translation to `app_ru.arb`.
2. Run `flutter gen-l10n` (or `flutter pub get` if `generate: true` is enabled).
3. Use `l10n.myKey` in the widget.
