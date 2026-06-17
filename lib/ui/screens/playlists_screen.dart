import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/playlist/create_playlist_dialog.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);
    final routeNotifier = ref.read(libraryRouteProvider.notifier);
    final actions = ref.read(playlistActionsProvider);

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.playlists,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showCreatePlaylistDialog(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(l10n.createPlaylist),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _PlaylistTile(
                  playlist: playlist,
                  displayName: playlistDisplayName(l10n, playlist),
                  trackCountLabel:
                      l10n.playlistsTrackCount(playlist.trackCount),
                  onTap: () => routeNotifier.openPlaylist(playlist.id),
                  onDelete: playlist.isSystem
                      ? null
                      : () => _confirmDeletePlaylist(
                            context,
                            l10n,
                            actions,
                            playlist,
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePlaylist(
    BuildContext context,
    AppLocalizations l10n,
    PlaylistActions actions,
    Playlist playlist,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.deletePlaylist),
        content: Text(
          l10n.confirmDeletePlaylist(playlist.name),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.deletePlaylist,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      actions.deletePlaylist(playlist.id);
    }
  }
}

class _PlaylistTile extends StatefulWidget {
  const _PlaylistTile({
    required this.playlist,
    required this.displayName,
    required this.trackCountLabel,
    required this.onTap,
    this.onDelete,
  });

  final Playlist playlist;
  final String displayName;
  final String trackCountLabel;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<_PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<_PlaylistTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surfaceElevated.withValues(alpha: 0.65)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  LucideIcons.listMusic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.trackCountLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered && widget.onDelete != null)
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: AppLocalizations.of(context).deletePlaylist,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
