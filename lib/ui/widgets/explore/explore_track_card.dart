import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/explore/explore_track_cover.dart';

class ExploreTrackCard extends ConsumerStatefulWidget {
  const ExploreTrackCard({super.key, required this.track});

  final ExploreTrack track;

  @override
  ConsumerState<ExploreTrackCard> createState() => _ExploreTrackCardState();
}

class _ExploreTrackCardState extends ConsumerState<ExploreTrackCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ytdlpAvailable = ref.watch(ytdlpAvailableProvider).value ?? false;
    final loadingVideoId = ref.watch(exploreLoadingVideoIdProvider);
    final isLoading = loadingVideoId == widget.track.videoId;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: ytdlpAvailable && !isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: ytdlpAvailable && !isLoading
            ? () => ref
                .read(playerUiStateProvider.notifier)
                .playExploreTrack(widget.track)
            : null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final coverSize = constraints.maxWidth.isFinite
                ? constraints.maxWidth - 24
                : 136.0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.surfaceElevated.withValues(alpha: 0.65)
                    : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExploreTrackCover(track: widget.track, size: coverSize),
                  const SizedBox(height: 12),
                  Text(
                    widget.track.title,
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
                    widget.track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
