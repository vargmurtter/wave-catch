import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';
import 'package:music_player/ui/widgets/common/frosted_panel.dart';

class QueuePanel extends ConsumerWidget {
  const QueuePanel({super.key});

  static const _width = 350.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playerState = ref.watch(playerUiStateProvider);
    final currentTrack = playerState.currentTrack;

    return FrostedPanel(
      color: AppColors.queueOverlay,
      blurSigma: 20,
      border: const Border(
        left: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.currentPlaylist,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(playerUiStateProvider.notifier).closeQueue(),
                    icon: const Icon(LucideIcons.x),
                    color: AppColors.textSecondary,
                    tooltip: l10n.close,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: playerState.queue.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final track = playerState.queue[index];
                  final isCurrent = track.id == currentTrack?.id;
                  return _QueueTrackTile(
                    track: track,
                    isCurrent: isCurrent,
                    onTap: () => ref
                        .read(playerUiStateProvider.notifier)
                        .jumpToIndex(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueTrackTile extends StatefulWidget {
  const _QueueTrackTile({
    required this.track,
    required this.isCurrent,
    required this.onTap,
  });

  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  State<_QueueTrackTile> createState() => _QueueTrackTileState();
}

class _QueueTrackTileState extends State<_QueueTrackTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: widget.isCurrent || _isHovered
              ? AppColors.surfaceElevated
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (widget.isCurrent)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    LucideIcons.audioLines,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              CoverArt(
                size: 40,
                seed: widget.track.id,
                imagePath: widget.track.albumArtUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            widget.isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: widget.isCurrent
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.track.artist,
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
          ),
        ),
      ),
    );
  }
}
