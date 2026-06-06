import 'package:flutter/material.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/detail_back_button.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/track/track_list_tile.dart';

class ArtistTracksScreen extends StatelessWidget {
  const ArtistTracksScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context) {
    final artist = MockData.artistById(artistId);
    if (artist == null) {
      return const Center(
        child: Text(
          'Исполнитель не найден',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final tracks = MockData.tracksForArtist(artistId);

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
                  'Все треки',
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
