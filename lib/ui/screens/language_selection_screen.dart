import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_locale.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/screens/onboarding_screen.dart';
import 'package:music_player/ui/shell/app_shell.dart';
import 'package:music_player/ui/theme/app_colors.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) async {
    await ref.read(appSettingsStateProvider.notifier).setLanguage(language);
    if (!context.mounted) return;

    final settings = ref.read(appSettingsStateProvider);
    final nextScreen = settings.isConfigured
        ? const AppShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  LucideIcons.languages,
                  color: AppColors.accent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.languageTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.languageSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _LanguageButton(
                  label: l10n.languageEnglish,
                  onPressed: () =>
                      _selectLanguage(context, ref, AppLanguage.en),
                ),
                const SizedBox(height: 12),
                _LanguageButton(
                  label: l10n.languageRussian,
                  onPressed: () =>
                      _selectLanguage(context, ref, AppLanguage.ru),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatefulWidget {
  const _LanguageButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surfaceElevated.withValues(alpha: 0.8)
                : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppColors.accent : AppColors.divider,
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
