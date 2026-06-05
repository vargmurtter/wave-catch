import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
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

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Главное'),
          ),
          ContentSection(
            title: 'Последнее прослушанное',
            fullBleedChild: true,
            child: HorizontalCardList(
              itemCount: sections.recentlyPlayed.length,
              itemBuilder: (context, index) {
                return RecentTrackTile(
                  track: sections.recentlyPlayed[index],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          ContentSection(
            title: 'Последнее добавленное',
            fullBleedChild: true,
            child: HorizontalCardList(
              itemCount: sections.recentlyAdded.length,
              itemBuilder: (context, index) {
                return AlbumCard(album: sections.recentlyAdded[index]);
              },
            ),
          ),
          const SizedBox(height: 32),
          ContentSection(
            title: 'Любимые альбомы',
            fullBleedChild: true,
            child: HorizontalCardList(
              itemCount: sections.favoriteAlbums.length,
              itemBuilder: (context, index) {
                return AlbumCard(album: sections.favoriteAlbums[index]);
              },
            ),
          ),
          const SizedBox(height: 32),
          ContentSection(
            title: 'Любимые исполнители',
            fullBleedChild: true,
            child: HorizontalCardList(
              itemCount: sections.favoriteArtists.length,
              itemBuilder: (context, index) {
                return ArtistCard(artist: sections.favoriteArtists[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
