import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/services/scanner/scan_job.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _message;

  Future<void> _changeFolder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Изменить папку с музыкой?'),
        content: const Text(
          'Текущий индекс останется в прежней папке. '
          'Для новой папки будет создан новый library.db и выполнено сканирование.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Изменить',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final path =
        await ref.read(appSettingsStateProvider.notifier).pickMusicFolder();
    if (path == null || !mounted) return;

    await ref.read(appSettingsStateProvider.notifier).setMusicLibraryPath(path);
    await _runScan(path, ScanMode.initial);
  }

  Future<void> _rescan() async {
    final path = ref.read(appSettingsStateProvider).musicLibraryPath;
    if (path == null) return;
    await _runScan(path, ScanMode.rescan);
  }

  Future<void> _runScan(String path, ScanMode mode) async {
    setState(() => _message = null);

    final result = await ref.read(libraryScanStateProvider.notifier).scanLibrary(
          musicRoot: path,
          mode: mode,
        );

    if (!mounted) return;

    if (result != null) {
      setState(
        () => _message =
            'Готово: ${result.trackCount} треков, ${result.albumCount} альбомов, '
            '${result.artistCount} исполнителей',
      );
    } else {
      final error = ref.read(libraryScanStateProvider).errorMessage;
      setState(() => _message = error ?? 'Ошибка сканирования');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsStateProvider);
    final scanState = ref.watch(libraryScanStateProvider);
    final isScanning = scanState.status == LibraryScanStatus.scanning;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Настройки'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Папка с музыкой',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    settings.musicLibraryPath ?? 'Не выбрана',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isScanning) ...[
                  LinearProgressIndicator(
                    value: scanState.progress?.fraction,
                    color: AppColors.accent,
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scanState.progress?.currentPath ?? 'Сканирование…',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  _SettingsButton(
                    icon: LucideIcons.folderOpen,
                    label: 'Изменить папку',
                    onTap: _changeFolder,
                  ),
                  const SizedBox(height: 8),
                  if (settings.isConfigured)
                    _SettingsButton(
                      icon: LucideIcons.refreshCw,
                      label: 'Пересканировать',
                      onTap: _rescan,
                    ),
                ],
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surfaceElevated.withValues(alpha: 0.8)
                : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
