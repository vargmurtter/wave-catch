import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/playlist/create_playlist_dialog.dart';

Future<void> showAddToPlaylistDialog(
  BuildContext context,
  WidgetRef ref,
  Track track,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AddToPlaylistDialog(track: track),
  );
}

class AddToPlaylistDialog extends ConsumerWidget {
  const AddToPlaylistDialog({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);
    final containingIds = ref.watch(trackPlaylistIdsProvider(track.id));
    final actions = ref.read(playlistActionsProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.addToPlaylist),
      content: SizedBox(
        width: 320,
        child: playlists.isEmpty
            ? Text(
                l10n.playlistEmpty,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: playlists.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final isInPlaylist = containingIds.contains(playlist.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isInPlaylist
                          ? LucideIcons.circleCheck
                          : LucideIcons.listMusic,
                      color: isInPlaylist
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(playlistDisplayName(l10n, playlist)),
                    subtitle: Text(
                      l10n.playlistsTrackCount(playlist.trackCount),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    enabled: !isInPlaylist,
                    onTap: isInPlaylist
                        ? null
                        : () {
                            actions.addTrackToPlaylist(playlist.id, track.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.addedToPlaylist)),
                            );
                          },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final playlist = await showCreatePlaylistDialog(context);
            if (playlist == null || !context.mounted) return;
            actions.addTrackToPlaylist(playlist.id, track.id);
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.addedToPlaylist)),
            );
          },
          child: Text(
            l10n.createPlaylist,
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
