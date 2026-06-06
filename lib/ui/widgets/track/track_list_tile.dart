import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';

class TrackListTile extends ConsumerStatefulWidget {
  const TrackListTile({
    super.key,
    required this.track,
    this.showTrackNumber = false,
    this.showArtist = true,
    this.showAlbum = false,
  });

  final Track track;
  final bool showTrackNumber;
  final bool showArtist;
  final bool showAlbum;

  @override
  ConsumerState<TrackListTile> createState() => _TrackListTileState();
}

class _TrackListTileState extends ConsumerState<TrackListTile> {
  bool _isHovered = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.showAlbum
        ? (widget.track.album ?? '')
        : widget.showArtist
            ? widget.track.artist
            : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            ref.read(trackInfoPanelProvider.notifier).open(widget.track),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surfaceElevated.withValues(alpha: 0.65)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (widget.showTrackNumber) ...[
                SizedBox(
                  width: 32,
                  child: Text(
                    '${widget.track.trackNumber ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
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
              if (_isHovered)
                IconButton(
                  onPressed: () => ref
                      .read(playerUiStateProvider.notifier)
                      .playTrackInAlbum(widget.track),
                  icon: const Icon(LucideIcons.play, size: 18),
                  color: AppColors.textPrimary,
                  tooltip: 'Воспроизвести',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                )
              else
                Text(
                  _formatDuration(widget.track.duration),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
