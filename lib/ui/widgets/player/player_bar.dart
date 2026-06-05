import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/repeat_mode.dart';
import 'package:music_player/ui/models/track.dart';
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
    final track = playerState.currentTrack;

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
          SizedBox(
            height: 2,
            child: LinearProgressIndicator(
              value: playerState.progress,
              backgroundColor: Colors.transparent,
              color: AppColors.accent,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _TrackInfo(track: track),
                  ),
                  Expanded(
                    flex: 4,
                    child: _PlaybackControls(
                      isPlaying: playerState.isPlaying,
                      shuffleEnabled: playerState.shuffleEnabled,
                      repeatMode: playerState.repeatMode,
                      onTogglePlayPause: notifier.togglePlayPause,
                      onToggleShuffle: notifier.toggleShuffle,
                      onCycleRepeat: notifier.cycleRepeatMode,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _RightControls(
                      volume: playerState.volume,
                      onVolumeChanged: notifier.setVolume,
                      onToggleQueue: notifier.toggleQueue,
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

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoverArt(size: 56, seed: track.id),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                track.artist,
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
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.onTogglePlayPause,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
  });

  final bool isPlaying;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: LucideIcons.shuffle,
          isActive: shuffleEnabled,
          onPressed: onToggleShuffle,
          tooltip: 'Случайный порядок',
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: LucideIcons.skipBack,
          onPressed: () {},
          tooltip: 'Предыдущий трек',
        ),
        const SizedBox(width: 8),
        _PlayPauseButton(
          isPlaying: isPlaying,
          onPressed: onTogglePlayPause,
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: LucideIcons.skipForward,
          onPressed: () {},
          tooltip: 'Следующий трек',
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: repeatMode == RepeatMode.one
              ? LucideIcons.repeat1
              : LucideIcons.repeat,
          isActive: repeatMode != RepeatMode.off,
          onPressed: onCycleRepeat,
          tooltip: 'Повтор',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ControlButton(
          icon: LucideIcons.listMusic,
          onPressed: onToggleQueue,
          tooltip: 'Текущий плейлист',
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
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String? tooltip;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? AppColors.accent
        : _isHovered
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
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
    required this.onPressed,
  });

  final bool isPlaying;
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
      cursor: SystemMouseCursors.click,
      child: IconButton(
        onPressed: widget.onPressed,
        tooltip: widget.isPlaying ? 'Пауза' : 'Воспроизведение',
        icon: Icon(
          widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
          size: 22,
        ),
        style: IconButton.styleFrom(
          backgroundColor: _isHovered
              ? AppColors.accent.withValues(alpha: 0.85)
              : AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
