import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/screens/onboarding_screen.dart';
import 'package:music_player/ui/shell/app_shell.dart';
import 'package:music_player/ui/theme/app_theme.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsStateProvider);

    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: settings.isConfigured ? const AppShell() : const OnboardingScreen(),
    );
  }
}
