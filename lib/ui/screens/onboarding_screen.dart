import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/ui/shell/app_shell.dart';
import 'package:music_player/ui/theme/app_colors.dart';

enum _OnboardingPhase { idle, pickingFolder, scanning }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingPhase _phase = _OnboardingPhase.idle;
  String? _error;

  Future<void> _pickFolder() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _phase = _OnboardingPhase.pickingFolder;
      _error = null;
    });

    try {
      final path = await ref
          .read(appSettingsStateProvider.notifier)
          .pickMusicFolder(dialogTitle: l10n.pickMusicFolderDialog);
      if (!mounted) return;

      if (path == null) {
        setState(() => _phase = _OnboardingPhase.idle);
        return;
      }

      await ref.read(appSettingsStateProvider.notifier).setMusicLibraryPath(path);

      setState(() => _phase = _OnboardingPhase.scanning);

      final result =
          await ref.read(libraryScanStateProvider.notifier).scanLibrary(
                musicRoot: path,
                mode: ScanMode.initial,
              );

      if (!mounted) return;

      if (result == null) {
        final scanState = ref.read(libraryScanStateProvider);
        setState(() {
          _phase = _OnboardingPhase.idle;
          _error = scanState.errorMessage ?? l10n.scanFailed;
        });
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _OnboardingPhase.idle;
        _error = l10n.folderPickerFailed(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanState = ref.watch(libraryScanStateProvider);
    final isScanning = _phase == _OnboardingPhase.scanning ||
        scanState.status == LibraryScanStatus.scanning;
    final isPickingFolder = _phase == _OnboardingPhase.pickingFolder;

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
                  LucideIcons.folderOpen,
                  color: AppColors.accent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.welcomeDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (isPickingFolder) ...[
                  const LinearProgressIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.folderPickerHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ] else if (isScanning) ...[
                  LinearProgressIndicator(
                    value: scanState.progress?.fraction,
                    color: AppColors.accent,
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scanState.progress?.currentPath ?? l10n.scanning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else
                  _PrimaryButton(
                    label: l10n.pickMusicFolder,
                    onPressed: _pickFolder,
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
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
                ? AppColors.accent.withValues(alpha: 0.9)
                : AppColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
