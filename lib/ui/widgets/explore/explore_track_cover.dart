import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';

class ExploreTrackCover extends ConsumerWidget {
  const ExploreTrackCover({
    super.key,
    required this.track,
    required this.size,
  });

  final ExploreTrack track;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingVideoId = ref.watch(exploreLoadingVideoIdProvider);
    final isLoading = loadingVideoId == track.videoId;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CoverArt(
            size: size,
            seed: track.videoId,
            imageUrl: track.thumbnailUrl,
          ),
          if (isLoading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
