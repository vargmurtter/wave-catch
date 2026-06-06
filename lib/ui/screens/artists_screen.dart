import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/artist_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180,
    mainAxisSpacing: 24,
    crossAxisSpacing: 24,
    mainAxisExtent: 220,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider);
    final routeNotifier = ref.read(libraryRouteProvider.notifier);

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Исполнители'),
          ),
          if (artists.isEmpty)
            const _EmptyLibraryMessage(
              message: 'Исполнители не найдены. Проверьте папку с музыкой в настройках.',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _gridDelegate,
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return ArtistCard(
                    artist: artist,
                    enableHoverScale: false,
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

class _EmptyLibraryMessage extends StatelessWidget {
  const _EmptyLibraryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
