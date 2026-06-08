import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/app_info.dart';
import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_locale.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/screens/language_selection_screen.dart';
import 'package:music_player/ui/screens/onboarding_screen.dart';
import 'package:music_player/ui/shell/app_shell.dart';
import 'package:music_player/ui/theme/app_theme.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsStateProvider);

    return MaterialApp(
      title: kAppDisplayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: settings.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _resolveHome(settings),
    );
  }

  Widget _resolveHome(AppSettingsState settings) {
    if (!settings.hasLanguageSelected) {
      return const LanguageSelectionScreen();
    }
    if (!settings.isConfigured) {
      return const OnboardingScreen();
    }
    return const AppShell();
  }
}
