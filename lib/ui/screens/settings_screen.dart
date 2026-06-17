import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_locale.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/l10n/l10n_extensions.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';
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
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.changeMusicFolderTitle),
        content: Text(
          l10n.changeMusicFolderBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.change,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final path = await ref
        .read(appSettingsStateProvider.notifier)
        .pickMusicFolder(dialogTitle: l10n.pickMusicFolderDialog);
    if (path == null || !mounted) return;

    await ref.read(appSettingsStateProvider.notifier).setMusicLibraryPath(path);
    await _runScan(path, ScanMode.initial);
  }

  Future<void> _rescan() async {
    final path = ref.read(appSettingsStateProvider).musicLibraryPath;
    if (path == null) return;
    await _runScan(path, ScanMode.rescan);
  }

  Future<void> _onGroupingStrategyChanged(
    AlbumGroupingStrategy strategy,
  ) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(appSettingsStateProvider).albumGroupingStrategy;
    if (current == strategy) return;

    final rescanNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.changeGroupingTitle),
        content: Text(
          l10n.changeGroupingBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.later),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.rescanNow,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    await ref
        .read(appSettingsStateProvider.notifier)
        .setAlbumGroupingStrategy(strategy);

    if (rescanNow == true) {
      final path = ref.read(appSettingsStateProvider).musicLibraryPath;
      if (path != null) {
        await _runScan(path, ScanMode.rescan);
      }
    }
  }

  Future<void> _runScan(String path, ScanMode mode) async {
    setState(() => _message = null);

    final result = await ref.read(libraryScanStateProvider.notifier).scanLibrary(
          musicRoot: path,
          mode: mode,
        );

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (result != null) {
      setState(
        () => _message = l10n.scanComplete(
          result.trackCount,
          result.albumCount,
          result.artistCount,
        ),
      );
    } else {
      final error = ref.read(libraryScanStateProvider).errorMessage;
      setState(() => _message = error ?? l10n.scanError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsStateProvider);
    final scanState = ref.watch(libraryScanStateProvider);
    final isScanning = scanState.status == LibraryScanStatus.scanning;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ScreenHeader(title: l10n.settingsTitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...AppLanguage.values.map(
                  (language) => _LanguageTile(
                    label: language == AppLanguage.en
                        ? l10n.languageEnglish
                        : l10n.languageRussian,
                    isSelected: settings.language == language,
                    onChanged: () => ref
                        .read(appSettingsStateProvider.notifier)
                        .setLanguage(language),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.settingsYtdlpStatus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ref.watch(ytdlpAvailableProvider).when(
                  data: (available) {
                    if (!available) {
                      return Text(
                        l10n.settingsYtdlpMissing,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return ref.watch(ytdlpVersionProvider).when(
                      data: (version) => Text(
                        l10n.settingsYtdlpAvailable(version ?? ''),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      loading: () => Text(
                        l10n.settingsYtdlpAvailable('…'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      error: (_, __) => Text(
                        l10n.settingsYtdlpAvailable(''),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Text(
                    l10n.settingsYtdlpMissing,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.musicFolder,
                  style: const TextStyle(
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
                    settings.musicLibraryPath ?? l10n.notSelected,
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
                    scanState.progress?.currentPath ?? l10n.scanning,
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
                    label: l10n.changeFolder,
                    onTap: _changeFolder,
                  ),
                  const SizedBox(height: 8),
                  if (settings.isConfigured)
                    _SettingsButton(
                      icon: LucideIcons.refreshCw,
                      label: l10n.rescan,
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
                const SizedBox(height: 32),
                Text(
                  l10n.albumGrouping,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...AlbumGroupingStrategy.values.map(
                  (strategy) => _GroupingStrategyTile(
                    strategy: strategy,
                    groupValue: settings.albumGroupingStrategy,
                    enabled: !isScanning,
                    onChanged: _onGroupingStrategyChanged,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.metadataEditing,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...MetadataEditMode.values.map(
                  (mode) => _MetadataEditModeTile(
                    mode: mode,
                    groupValue: settings.metadataEditMode,
                    enabled: !isScanning,
                    onChanged: (value) => ref
                        .read(appSettingsStateProvider.notifier)
                        .setMetadataEditMode(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatefulWidget {
  const _LanguageTile({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onChanged;

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onChanged,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceElevated.withValues(alpha: 0.8)
                  : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected ? AppColors.accent : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isSelected
                      ? LucideIcons.circleDot
                      : LucideIcons.circle,
                  size: 18,
                  color: widget.isSelected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupingStrategyTile extends StatefulWidget {
  const _GroupingStrategyTile({
    required this.strategy,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
  });

  final AlbumGroupingStrategy strategy;
  final AlbumGroupingStrategy groupValue;
  final bool enabled;
  final ValueChanged<AlbumGroupingStrategy> onChanged;

  @override
  State<_GroupingStrategyTile> createState() => _GroupingStrategyTileState();
}

class _GroupingStrategyTileState extends State<_GroupingStrategyTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSelected = widget.strategy == widget.groupValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor:
            widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? () => widget.onChanged(widget.strategy) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered && widget.enabled
                  ? AppColors.surfaceElevated.withValues(alpha: 0.8)
                  : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isSelected
                        ? LucideIcons.circleDot
                        : LucideIcons.circle,
                    size: 18,
                    color:
                        isSelected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.strategy.labelL10n(l10n),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.strategy.isRecommended) ...[
                            const SizedBox(width: 8),
                            Text(
                              l10n.recommended,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.strategy.descriptionL10n(l10n),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataEditModeTile extends StatefulWidget {
  const _MetadataEditModeTile({
    required this.mode,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
  });

  final MetadataEditMode mode;
  final MetadataEditMode groupValue;
  final bool enabled;
  final ValueChanged<MetadataEditMode> onChanged;

  @override
  State<_MetadataEditModeTile> createState() => _MetadataEditModeTileState();
}

class _MetadataEditModeTileState extends State<_MetadataEditModeTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSelected = widget.mode == widget.groupValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor:
            widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? () => widget.onChanged(widget.mode) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered && widget.enabled
                  ? AppColors.surfaceElevated.withValues(alpha: 0.8)
                  : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isSelected
                        ? LucideIcons.circleDot
                        : LucideIcons.circle,
                    size: 18,
                    color:
                        isSelected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mode.labelL10n(l10n),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mode.descriptionL10n(l10n),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
