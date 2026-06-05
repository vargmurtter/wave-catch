import 'package:flutter/material.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/widgets/home/artist_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180,
    mainAxisSpacing: 24,
    crossAxisSpacing: 24,
    mainAxisExtent: 220,
  );

  @override
  Widget build(BuildContext context) {
    final artists = MockData.artists;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Исполнители'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _gridDelegate,
              itemCount: artists.length,
              itemBuilder: (context, index) {
                return ArtistCard(
                  artist: artists[index],
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
