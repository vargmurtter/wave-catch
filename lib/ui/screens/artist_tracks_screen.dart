import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/detail_back_button.dart';
import 'package:music_player/ui/widgets/common/play_action_button.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/track/track_list_tile.dart';

class ArtistTracksScreen extends ConsumerWidget {
  const ArtistTracksScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final artist = ref.watch(artistByIdProvider(artistId));
    if (artist == null) {
      return Center(
        child: Text(
          l10n.artistNotFound,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final tracks = ref.watch(tracksForArtistProvider(artistId));
    final playerNotifier = ref.read(playerUiStateProvider.notifier);

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
                Text(
                  l10n.allTracks,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  artist.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (tracks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  PlayActionButton(
                    onPressed: () => playerNotifier.playArtist(artistId),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final track in tracks)
                  TrackListTile(track: track, showAlbum: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
