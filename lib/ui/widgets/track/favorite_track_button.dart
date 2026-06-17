import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/playlist/add_to_playlist_dialog.dart';

class FavoriteTrackButton extends ConsumerWidget {
  const FavoriteTrackButton({
    super.key,
    required this.track,
    this.iconSize = 18,
    this.compact = false,
  });

  final Track track;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = ref.watch(isTrackFavoriteProvider(track.id));
    final actions = ref.read(playlistActionsProvider);

    final icon = Icon(
      LucideIcons.heart,
      size: iconSize,
      fill: isFavorite ? 1.0 : 0.0,
    );

    if (compact) {
      return IconButton(
        onPressed: () => actions.toggleFavorite(track.id),
        icon: icon,
        color: isFavorite ? AppColors.accent : AppColors.textSecondary,
        tooltip: l10n.favorites,
        style: IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
      );
    }

    return IconButton(
      onPressed: () => actions.toggleFavorite(track.id),
      icon: icon,
      color: isFavorite ? AppColors.accent : AppColors.textSecondary,
      tooltip: l10n.favorites,
    );
  }
}

class AddToPlaylistButton extends ConsumerWidget {
  const AddToPlaylistButton({
    super.key,
    required this.track,
    this.iconSize = 18,
  });

  final Track track;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      onPressed: () => showAddToPlaylistDialog(context, ref, track),
      icon: Icon(LucideIcons.listPlus, size: iconSize),
      color: AppColors.textSecondary,
      tooltip: l10n.addToPlaylist,
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
