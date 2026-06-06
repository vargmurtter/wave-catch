import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/album_card.dart';
import 'package:music_player/ui/widgets/home/artist_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/home/horizontal_card_list.dart';
import 'package:music_player/ui/widgets/home/recent_track_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homeSectionsProvider);
    final routeNotifier = ref.read(libraryRouteProvider.notifier);
    final trackInfoNotifier = ref.read(trackInfoPanelProvider.notifier);

    final isEmpty = sections.recentlyAdded.isEmpty &&
        sections.favoriteAlbums.isEmpty &&
        sections.favoriteArtists.isEmpty;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Главное'),
          ),
          if (isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                'Библиотека пуста. Добавьте музыку в выбранную папку '
                'и нажмите «Пересканировать» в настройках.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (sections.recentlyPlayed.isNotEmpty) ...[
            ContentSection(
              title: 'Последнее прослушанное',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: sections.recentlyPlayed.length,
                itemBuilder: (context, index) {
                  final track = sections.recentlyPlayed[index];
                  return RecentTrackTile(
                    track: track,
                    onTap: () => trackInfoNotifier.open(track),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          if (sections.recentlyAdded.isNotEmpty) ...[
            ContentSection(
              title: 'Последнее добавленное',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: sections.recentlyAdded.length,
                itemBuilder: (context, index) {
                  final album = sections.recentlyAdded[index];
                  return AlbumCard(
                    album: album,
                    onTap: () => routeNotifier.openAlbum(album.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          if (sections.favoriteAlbums.isNotEmpty) ...[
            ContentSection(
              title: 'Любимые альбомы',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: sections.favoriteAlbums.length,
                itemBuilder: (context, index) {
                  final album = sections.favoriteAlbums[index];
                  return AlbumCard(
                    album: album,
                    onTap: () => routeNotifier.openAlbum(album.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          if (sections.favoriteArtists.isNotEmpty)
            ContentSection(
              title: 'Любимые исполнители',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: sections.favoriteArtists.length,
                itemBuilder: (context, index) {
                  final artist = sections.favoriteArtists[index];
                  return ArtistCard(
                    artist: artist,
                    onTap: () => routeNotifier.openArtist(artist.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
