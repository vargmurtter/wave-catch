import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/playable_item.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';
import 'package:music_player/ui/widgets/common/frosted_panel.dart';
import 'package:music_player/ui/widgets/player/volume_control.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  static const _height = 96.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerUiStateProvider);
    final notifier = ref.read(playerUiStateProvider.notifier);
    final item = playerState.currentItem;
    final isExplore = playerState.isExplorePlayback;
    final exploreTrack = item?.exploreTrack;
    final isSaved = exploreTrack != null &&
        ref.watch(exploreSavedVideoIdsProvider).contains(exploreTrack.videoId);
    final savingVideoId = ref.watch(exploreSavingVideoIdProvider);
    final isSaving =
        exploreTrack != null && savingVideoId == exploreTrack.videoId;

    return FrostedPanel(
      color: AppColors.playerOverlay,
      blurSigma: 24,
      border: const Border(
        top: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      child: SizedBox(
        height: _height,
        child: Column(
          children: [
            _ProgressBar(
              progress: playerState.progress,
              duration: playerState.duration,
              enabled: item != null,
              onSeek: notifier.seek,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: item != null
                          ? _TrackInfo(item: item, isExplore: isExplore)
                          : const _EmptyTrackInfo(),
                    ),
                    Expanded(
                      flex: 4,
                      child: _PlaybackControls(
                        isPlaying: playerState.isPlaying,
                        isLoading: playerState.isLoading,
                        shuffleEnabled: playerState.shuffleEnabled,
                        repeatMode: playerState.repeatMode,
                        enabled: item != null,
                        onTogglePlayPause: notifier.togglePlayPause,
                        onToggleShuffle: notifier.toggleShuffle,
                        onCycleRepeat: notifier.cycleRepeatMode,
                        onSkipPrevious: notifier.skipPrevious,
                        onSkipNext: notifier.skipNext,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isExplore && exploreTrack != null && !isSaved)
                            TextButton.icon(
                              onPressed: isSaving || playerState.isLoading
                                  ? null
                                  : () async {
                                      final error = await ref
                                          .read(exploreSaveProvider.notifier)
                                          .save(exploreTrack);
                                      if (error != null && context.mounted) {
                                        final l10n =
                                            AppLocalizations.of(context);
                                        final message =
                                            error == 'age_restricted'
                                                ? l10n.exploreSaveAgeRestricted
                                                : (error.isNotEmpty
                                                    ? error
                                                    : l10n.exploreSaveFailed);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                      }
                                    },
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      LucideIcons.download,
                                      size: 16,
                                    ),
                              label: Text(
                                isSaving
                                    ? AppLocalizations.of(context)
                                        .exploreSaving
                                    : AppLocalizations.of(context)
                                        .exploreSaveToLibrary,
                              ),
                            ),
                          _RightControls(
                            volume: playerState.volume,
                            onVolumeChanged: notifier.setVolume,
                            onToggleQueue: notifier.toggleQueue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatefulWidget {
  const _ProgressBar({
    required this.progress,
    required this.duration,
    required this.enabled,
    required this.onSeek,
  });

  final double progress;
  final Duration duration;
  final bool enabled;
  final Future<void> Function(Duration position) onSeek;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.progress;

    return SizedBox(
      height: 12,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
          overlayShape: SliderComponentShape.noOverlay,
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.divider,
          disabledActiveTrackColor: AppColors.divider,
          disabledInactiveTrackColor: AppColors.divider,
        ),
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: widget.enabled
                ? (next) => setState(() => _dragValue = next)
                : null,
            onChangeEnd: widget.enabled
                ? (next) {
                    setState(() => _dragValue = null);
                    final totalMs = widget.duration.inMilliseconds;
                    if (totalMs <= 0) return;
                    widget.onSeek(
                      Duration(milliseconds: (next * totalMs).round()),
                    );
                  }
                : null,
          ),
        ),
      ),
    );
  }
}

class _EmptyTrackInfo extends StatelessWidget {
  const _EmptyTrackInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            LucideIcons.music,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context).selectTrack,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.item, required this.isExplore});

  final PlayableItem item;
  final bool isExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final libraryTrack = item.libraryTrack;

    return Row(
      children: [
        CoverArt(
          size: 56,
          seed: item.id,
          imagePath: libraryTrack?.albumArtUrl,
          imageUrl: item.thumbnailUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isExplore)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.explorePreview,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.isPlaying,
    required this.isLoading,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.enabled,
    required this.onTogglePlayPause,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onSkipPrevious,
    required this.onSkipNext,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final bool enabled;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: LucideIcons.shuffle,
          isActive: shuffleEnabled,
          onPressed: onToggleShuffle,
          tooltip: l10n.shuffle,
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: LucideIcons.skipBack,
          onPressed: enabled ? onSkipPrevious : null,
          tooltip: l10n.previousTrack,
        ),
        const SizedBox(width: 8),
        _PlayPauseButton(
          isPlaying: isPlaying,
          isLoading: isLoading,
          enabled: enabled && !isLoading,
          onPressed: onTogglePlayPause,
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: LucideIcons.skipForward,
          onPressed: enabled ? onSkipNext : null,
          tooltip: l10n.nextTrack,
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: repeatMode == RepeatMode.one
              ? LucideIcons.repeat1
              : LucideIcons.repeat,
          isActive: repeatMode != RepeatMode.off,
          onPressed: onCycleRepeat,
          tooltip: l10n.repeat,
        ),
      ],
    );
  }
}

class _RightControls extends StatelessWidget {
  const _RightControls({
    required this.volume,
    required this.onVolumeChanged,
    required this.onToggleQueue,
  });

  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleQueue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ControlButton(
          icon: LucideIcons.listMusic,
          onPressed: onToggleQueue,
          tooltip: l10n.currentPlaylist,
        ),
        VolumeControl(
          volume: volume,
          onChanged: onVolumeChanged,
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    this.onPressed,
    this.isActive = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final String? tooltip;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = widget.isActive
        ? AppColors.accent
        : !enabled
            ? AppColors.textSecondary.withValues(alpha: 0.4)
            : _isHovered
                ? AppColors.textPrimary
                : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: IconButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        icon: Icon(widget.icon, size: 18),
        color: color,
        hoverColor: AppColors.surfaceElevated,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: IconButton(
        onPressed: widget.enabled ? widget.onPressed : null,
        tooltip: widget.isLoading
            ? AppLocalizations.of(context).exploreLoadingPreview
            : widget.isPlaying
                ? AppLocalizations.of(context).pause
                : AppLocalizations.of(context).play,
        icon: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              )
            : Icon(
                widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
                size: 22,
              ),
        style: IconButton.styleFrom(
          backgroundColor: widget.enabled
              ? (_isHovered
                  ? AppColors.accent.withValues(alpha: 0.85)
                  : AppColors.accent)
              : AppColors.surfaceElevated,
          foregroundColor: widget.enabled
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
