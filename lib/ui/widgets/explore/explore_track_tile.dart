import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';

class ExploreTrackTile extends ConsumerWidget {
  const ExploreTrackTile({super.key, required this.track});

  final ExploreTrack track;

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ytdlpAvailable = ref.watch(ytdlpAvailableProvider).value ?? false;
    final isSaved = ref.watch(exploreSavedVideoIdsProvider).contains(track.videoId);
    final savingVideoId = ref.watch(exploreSavingVideoIdProvider);
    final isSaving = savingVideoId == track.videoId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: ytdlpAvailable && !isSaving
              ? () => ref
                  .read(playerUiStateProvider.notifier)
                  .playExploreTrack(track)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                CoverArt(
                  size: 48,
                  seed: track.videoId,
                  imageUrl: track.thumbnailUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                if (track.duration > Duration.zero)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatDuration(track.duration),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (isSaved)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      l10n.exploreInLibrary,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: ytdlpAvailable && !isSaving
                        ? () async {
                            final error = await ref
                                .read(exploreSaveProvider.notifier)
                                .save(track);
                            if (error != null && context.mounted) {
                              final message = error == 'age_restricted'
                                  ? l10n.exploreSaveAgeRestricted
                                  : (error.isNotEmpty
                                      ? error
                                      : l10n.exploreSaveFailed);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          }
                        : null,
                    icon: isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.download, size: 16),
                    label: Text(
                      isSaving ? l10n.exploreSaving : l10n.exploreSaveToLibrary,
                    ),
                  ),
                IconButton(
                  onPressed: ytdlpAvailable && !isSaving
                      ? () => ref
                          .read(playerUiStateProvider.notifier)
                          .playExploreTrack(track)
                      : null,
                  icon: const Icon(LucideIcons.play, size: 18),
                  tooltip: l10n.play,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
