import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';
import 'package:music_player/ui/widgets/common/detail_back_button.dart';
import 'package:music_player/ui/widgets/common/play_action_button.dart';
import 'package:music_player/ui/widgets/home/album_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/home/horizontal_card_list.dart';
import 'package:music_player/ui/widgets/track/track_list_tile.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumByIdProvider(albumId));
    if (album == null) {
      return const Center(
        child: Text(
          'Альбом не найден',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final tracks = ref.watch(tracksForAlbumProvider(albumId));
    final otherAlbums = ref.watch(
      otherAlbumsByArtistProvider(
        (artistId: album.artistId, excludeAlbumId: albumId),
      ),
    );
    final routeNotifier = ref.read(libraryRouteProvider.notifier);
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CoverArt(
                      size: 200,
                      seed: album.id,
                      imagePath: album.coverUrl,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          _ArtistLink(
                            name: album.artist,
                            onTap: () =>
                                routeNotifier.openArtist(album.artistId),
                          ),
                          if (album.year != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${album.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (tracks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            PlayActionButton(
                              onPressed: () =>
                                  playerNotifier.playAlbum(albumId),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (tracks.isNotEmpty) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Треки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final track in tracks)
                    TrackListTile(
                      track: track,
                      showTrackNumber: true,
                      showArtist: false,
                    ),
                ],
              ),
            ),
          ],
          if (otherAlbums.isNotEmpty) ...[
            const SizedBox(height: 32),
            ContentSection(
              title: 'Другие альбомы',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: otherAlbums.length,
                itemBuilder: (context, index) {
                  final otherAlbum = otherAlbums[index];
                  return AlbumCard(
                    album: otherAlbum,
                    onTap: () => routeNotifier.openAlbum(otherAlbum.id),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtistLink extends StatefulWidget {
  const _ArtistLink({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  State<_ArtistLink> createState() => _ArtistLinkState();
}

class _ArtistLinkState extends State<_ArtistLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _isHovered ? AppColors.accent : AppColors.textSecondary,
            decoration: _isHovered ? TextDecoration.underline : null,
            decorationColor: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
