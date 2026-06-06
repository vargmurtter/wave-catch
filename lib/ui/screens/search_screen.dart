import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/search/search_result_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static void openArtist(WidgetRef ref, Artist artist) {
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(libraryRouteProvider.notifier).reset();
    ref.read(libraryRouteProvider.notifier).openArtist(artist.id);
  }

  static void openAlbum(WidgetRef ref, Album album) {
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(libraryRouteProvider.notifier).reset();
    ref.read(libraryRouteProvider.notifier).openAlbum(album.id);
  }

  static void openTrack(WidgetRef ref, Track track) {
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(libraryRouteProvider.notifier).reset();
    ref.read(playerUiStateProvider.notifier).playTrackInAlbum(track);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final debouncedQuery = ref.watch(debouncedSearchQueryProvider);
    final results = ref.watch(librarySearchResultsProvider);
    final isLoading =
        query.trim().isNotEmpty && query != debouncedQuery;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: ScreenHeader(title: 'Результаты поиска'),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                'Поиск…',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                'Ничего не найдено',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else ...[
            if (results.artists.isNotEmpty)
              ContentSection(
                title: 'Исполнители',
                child: Column(
                  children: [
                    for (final artist in results.artists)
                      _ArtistSearchResultTile(
                        artist: artist,
                        onTap: () => openArtist(ref, artist),
                      ),
                  ],
                ),
              ),
            if (results.albums.isNotEmpty) ...[
              if (results.artists.isNotEmpty) const SizedBox(height: 32),
              ContentSection(
                title: 'Альбомы',
                child: Column(
                  children: [
                    for (final album in results.albums)
                      SearchResultTile(
                        title: album.title,
                        subtitle: album.artist,
                        seed: album.id,
                        imagePath: album.coverUrl,
                        onTap: () => openAlbum(ref, album),
                      ),
                  ],
                ),
              ),
            ],
            if (results.tracks.isNotEmpty) ...[
              if (results.artists.isNotEmpty || results.albums.isNotEmpty)
                const SizedBox(height: 32),
              ContentSection(
                title: 'Треки',
                child: Column(
                  children: [
                    for (final track in results.tracks)
                      SearchResultTile(
                        title: track.title,
                        subtitle: _trackSubtitle(track),
                        seed: track.id,
                        imagePath: track.albumArtUrl,
                        trailing: _formatDuration(track.duration),
                        onTap: () => openTrack(ref, track),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _trackSubtitle(Track track) {
    final album = track.album;
    if (album != null && album.isNotEmpty) {
      return '${track.artist} · $album';
    }
    return track.artist;
  }
}

class _ArtistSearchResultTile extends ConsumerWidget {
  const _ArtistSearchResultTile({
    required this.artist,
    required this.onTap,
  });

  final Artist artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePathAsync =
        ref.watch(artistDisplayImagePathProvider(artist.id));
    final imagePath = imagePathAsync.value ?? artist.imageUrl;

    return SearchResultTile(
      title: artist.name,
      seed: artist.id,
      imagePath: imagePath,
      circular: true,
      onTap: onTap,
    );
  }
}
