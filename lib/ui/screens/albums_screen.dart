import 'package:flutter/material.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/widgets/home/album_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180,
    mainAxisSpacing: 24,
    crossAxisSpacing: 24,
    mainAxisExtent: 250,
  );

  @override
  Widget build(BuildContext context) {
    final albums = MockData.albums;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Альбомы'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _gridDelegate,
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return AlbumCard(
                  album: albums[index],
                  enableHoverScale: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
