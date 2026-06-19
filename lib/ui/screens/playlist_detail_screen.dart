import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/playlist_sort_order.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/detail_back_button.dart';
import 'package:music_player/ui/widgets/common/play_action_button.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/playlist/create_playlist_dialog.dart';
import 'package:music_player/ui/widgets/track/track_list_tile.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlist = ref.watch(playlistByIdProvider(playlistId));
    if (playlist == null) {
      return Center(
        child: Text(
          l10n.playlistNotFound,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final tracks = ref.watch(tracksForPlaylistProvider(playlistId));
    final playerNotifier = ref.read(playerUiStateProvider.notifier);
    final actions = ref.read(playlistActionsProvider);
    final displayName = playlistDisplayName(l10n, playlist);

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DetailBackButton(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.listMusic,
                        size: 72,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.playlistsTrackCount(playlist.trackCount),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (tracks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            PlayActionButton(
                              onPressed: () =>
                                  playerNotifier.playPlaylist(tracks),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (tracks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
              child: Text(
                l10n.playlistEmpty,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tracks,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  PopupMenuButton<PlaylistSortOrder>(
                    tooltip: l10n.playlistSortByAddedDate,
                    initialValue: playlist.sortOrder,
                    onSelected: (sortOrder) {
                      if (sortOrder == playlist.sortOrder) return;
                      actions.setPlaylistSortOrder(playlistId, sortOrder);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: PlaylistSortOrder.asc,
                        child: Row(
                          children: [
                            if (playlist.sortOrder == PlaylistSortOrder.asc)
                              const Icon(
                                LucideIcons.check,
                                size: 16,
                                color: AppColors.accent,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text(l10n.playlistSortOldestFirst),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: PlaylistSortOrder.desc,
                        child: Row(
                          children: [
                            if (playlist.sortOrder == PlaylistSortOrder.desc)
                              const Icon(
                                LucideIcons.check,
                                size: 16,
                                color: AppColors.accent,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text(l10n.playlistSortNewestFirst),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          playlist.sortOrder == PlaylistSortOrder.asc
                              ? LucideIcons.arrowUp
                              : LucideIcons.arrowDown,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          playlist.sortOrder == PlaylistSortOrder.asc
                              ? l10n.playlistSortOldestFirst
                              : l10n.playlistSortNewestFirst,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronDown,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final track in tracks)
                    TrackListTile(
                      track: track,
                      onPlay: () => playerNotifier.playPlaylist(
                        tracks,
                        startTrack: track,
                      ),
                      onRemove: () {
                        actions.removeTrackFromPlaylist(playlistId, track.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.removedFromPlaylist)),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
