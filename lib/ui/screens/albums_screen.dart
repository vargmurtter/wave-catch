import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/album_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180,
    mainAxisSpacing: 24,
    crossAxisSpacing: 24,
    mainAxisExtent: 250,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final albums = ref.watch(albumsProvider);
    final routeNotifier = ref.read(libraryRouteProvider.notifier);

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ScreenHeader(title: l10n.albums),
          ),
          if (albums.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                l10n.albumsNotFound,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _gridDelegate,
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return AlbumCard(
                    album: album,
                    enableHoverScale: false,
                    onTap: () => routeNotifier.openAlbum(album.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
