import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/artist/artist_hero_banner.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';
import 'package:music_player/ui/widgets/common/detail_back_button.dart';
import 'package:music_player/ui/widgets/common/play_action_button.dart';
import 'package:music_player/ui/widgets/home/album_card.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/home/horizontal_card_list.dart';
import 'package:music_player/ui/widgets/track/track_list_tile.dart';

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.artistId});

  final String artistId;

  static const _previewTrackCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistByIdProvider(artistId));
    if (artist == null) {
      return const Center(
        child: Text(
          'Исполнитель не найден',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final artistInfoAsync = ref.watch(artistInfoProvider(artistId));
    final artistInfo = artistInfoAsync.asData?.value;
    final isLoadingArtistInfo = artistInfoAsync.isLoading;
    final displayImageAsync = ref.watch(artistDisplayImagePathProvider(artistId));
    final cachedImageAsync = ref.watch(artistCachedImagePathProvider(artistId));
    final effectiveImagePath = displayImageAsync.value ?? artist.imageUrl;
    final cachedImagePath = cachedImageAsync.value;

    final albums = ref.watch(albumsForArtistProvider(artistId));
    final tracks = ref.watch(tracksForArtistProvider(artistId));
    final previewTracks = tracks.take(_previewTrackCount).toList();
    final routeNotifier = ref.read(libraryRouteProvider.notifier);
    final playerNotifier = ref.read(playerUiStateProvider.notifier);

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cachedImagePath != null)
            ArtistHeroBanner(imagePath: cachedImagePath),
          Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              cachedImagePath != null ? 0 : 24,
              32,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const DetailBackButton(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CoverArt(
                      size: 200,
                      circular: true,
                      seed: artist.id,
                      imagePath: effectiveImagePath,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (tracks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            PlayActionButton(
                              onPressed: () =>
                                  playerNotifier.playArtist(artistId),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (isLoadingArtistInfo) ...[
                  const SizedBox(height: 16),
                  const _ArtistInfoLoadingIndicator(),
                ],
                if (artistInfo?.description != null &&
                    artistInfo!.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    artistInfo.description!,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (albums.isNotEmpty) ...[
            const SizedBox(height: 32),
            ContentSection(
              title: 'Альбомы',
              fullBleedChild: true,
              child: HorizontalCardList(
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return AlbumCard(
                    album: album,
                    onTap: () => routeNotifier.openAlbum(album.id),
                  );
                },
              ),
            ),
          ],
          if (previewTracks.isNotEmpty) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Популярные треки',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (tracks.length > _previewTrackCount)
                    _ShowAllLink(
                      onTap: () => routeNotifier.openArtistTracks(artistId),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final track in previewTracks)
                    TrackListTile(track: track, showAlbum: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtistInfoLoadingIndicator extends StatelessWidget {
  const _ArtistInfoLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Загрузка информации…',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ShowAllLink extends StatefulWidget {
  const _ShowAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ShowAllLink> createState() => _ShowAllLinkState();
}

class _ShowAllLinkState extends State<_ShowAllLink> {
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
          'Показать все',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isHovered ? AppColors.accent : AppColors.textSecondary,
            decoration: _isHovered ? TextDecoration.underline : null,
            decorationColor: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
