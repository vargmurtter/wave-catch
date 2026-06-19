import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/theme/app_colors.dart';

class ExploreTrackSaveIconButton extends ConsumerWidget {
  const ExploreTrackSaveIconButton({super.key, required this.track});

  final ExploreTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ytdlpAvailable = ref.watch(ytdlpAvailableProvider).value ?? false;
    final isSaved =
        ref.watch(exploreSavedVideoIdsProvider).contains(track.videoId);
    final savingVideoId = ref.watch(exploreSavingVideoIdProvider);
    final isSaving = savingVideoId == track.videoId;

    if (isSaved) {
      return Tooltip(
        message: l10n.exploreInLibrary,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            LucideIcons.circleCheck,
            size: 16,
            color: AppColors.accent,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: ytdlpAvailable && !isSaving
          ? () async {
              final error =
                  await ref.read(exploreSaveProvider.notifier).save(track);
              if (error != null && context.mounted) {
                final message = error == 'age_restricted'
                    ? l10n.exploreSaveAgeRestricted
                    : (error.isNotEmpty ? error : l10n.exploreSaveFailed);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            }
          : null,
      tooltip: isSaving ? l10n.exploreSaving : l10n.exploreSaveToLibrary,
      icon: isSaving
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(LucideIcons.download, size: 14),
      style: IconButton.styleFrom(
        minimumSize: const Size(28, 28),
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.9),
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }
}
