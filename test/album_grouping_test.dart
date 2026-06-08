import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/services/scanner/album_grouping.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';

void main() {
  group('stripFeaturing', () {
    test('removes feat suffix', () {
      expect(stripFeaturing('Drake feat. Rihanna'), 'Drake');
      expect(stripFeaturing('Artist ft. Guest'), 'Artist');
      expect(stripFeaturing('Artist featuring Guest'), 'Artist');
    });

    test('leaves simple names unchanged', () {
      expect(stripFeaturing('Radiohead'), 'Radiohead');
      expect(stripFeaturing('  Trimmed  '), 'Trimmed');
    });
  });

  group('computeAlbumId', () {
    test('byAlbumArtist groups feat tracks with album artist tag', () {
      final mainTrack = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumArtist,
        albumTitle: 'Views',
        parentDir: '/music/Drake/Views',
        albumArtist: 'Drake',
        trackArtist: 'Drake',
      );
      final featTrack = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumArtist,
        albumTitle: 'Views',
        parentDir: '/music/Drake/Views',
        albumArtist: 'Drake',
        trackArtist: 'Drake feat. Rihanna',
      );

      expect(mainTrack, featTrack);
    });

    test('byAlbumArtist falls back to stripped track artist', () {
      final mainTrack = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumArtist,
        albumTitle: 'Views',
        parentDir: '/music/Drake/Views',
        albumArtist: null,
        trackArtist: 'Drake',
      );
      final featTrack = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumArtist,
        albumTitle: 'Views',
        parentDir: '/music/Drake/Views',
        albumArtist: null,
        trackArtist: 'Drake feat. Rihanna',
      );

      expect(mainTrack, featTrack);
    });

    test('byFolder separates different directories', () {
      final albumA = computeAlbumId(
        strategy: AlbumGroupingStrategy.byFolder,
        albumTitle: 'Greatest Hits',
        parentDir: '/music/Artist A/Greatest Hits',
        albumArtist: null,
        trackArtist: 'Artist A',
      );
      final albumB = computeAlbumId(
        strategy: AlbumGroupingStrategy.byFolder,
        albumTitle: 'Greatest Hits',
        parentDir: '/music/Artist B/Greatest Hits',
        albumArtist: null,
        trackArtist: 'Artist B',
      );

      expect(albumA, isNot(albumB));
    });

    test('byFolder groups same directory and album title', () {
      final trackOne = computeAlbumId(
        strategy: AlbumGroupingStrategy.byFolder,
        albumTitle: 'OK Computer',
        parentDir: '/music/Radiohead/OK Computer',
        albumArtist: null,
        trackArtist: 'Radiohead',
      );
      final trackTwo = computeAlbumId(
        strategy: AlbumGroupingStrategy.byFolder,
        albumTitle: 'OK Computer',
        parentDir: '/music/Radiohead/OK Computer',
        albumArtist: null,
        trackArtist: 'Radiohead feat. Guest',
      );

      expect(trackOne, trackTwo);
    });

    test('byAlbumTitle groups by title and year', () {
      final sameYear = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumTitle,
        albumTitle: 'Live',
        parentDir: '/music/a/Live',
        albumArtist: null,
        trackArtist: 'Artist A',
        year: 2020,
      );
      final sameYearOtherArtist = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumTitle,
        albumTitle: 'Live',
        parentDir: '/music/b/Live',
        albumArtist: null,
        trackArtist: 'Artist B',
        year: 2020,
      );
      final otherYear = computeAlbumId(
        strategy: AlbumGroupingStrategy.byAlbumTitle,
        albumTitle: 'Live',
        parentDir: '/music/a/Live',
        albumArtist: null,
        trackArtist: 'Artist A',
        year: 2021,
      );

      expect(sameYear, sameYearOtherArtist);
      expect(sameYear, isNot(otherYear));
    });
  });

  group('resolveAlbumArtist', () {
    test('prefers most common album artist tag', () {
      final result = resolveAlbumArtist(
        tracks: const [
          ResolvedTrackArtistInfo(
            artistId: 'a',
            artistName: 'Artist A',
            albumArtistName: 'Main Artist',
          ),
          ResolvedTrackArtistInfo(
            artistId: 'b',
            artistName: 'Artist B',
            albumArtistName: 'Main Artist',
          ),
        ],
      );

      expect(result.name, 'Main Artist');
    });

    test('uses single track artist when no album artist tags', () {
      final result = resolveAlbumArtist(
        tracks: const [
          ResolvedTrackArtistInfo(
            artistId: 'a',
            artistName: 'Artist A',
          ),
          ResolvedTrackArtistInfo(
            artistId: 'a',
            artistName: 'Artist A',
          ),
        ],
      );

      expect(result.name, 'Artist A');
    });

    test('falls back to various artists for mixed performers', () {
      final result = resolveAlbumArtist(
        tracks: const [
          ResolvedTrackArtistInfo(
            artistId: 'a',
            artistName: 'Artist A',
          ),
          ResolvedTrackArtistInfo(
            artistId: 'b',
            artistName: 'Artist B',
          ),
        ],
      );

      expect(result.name, 'Various artists');
    });
  });
}
