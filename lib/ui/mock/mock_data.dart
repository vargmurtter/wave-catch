import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/player_ui_state.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/models/track.dart';

abstract final class MockData {
  static const _tracks = [
    Track(
      id: '1',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      album: 'A Night at the Opera',
    ),
    Track(
      id: '2',
      title: 'Stairway to Heaven',
      artist: 'Led Zeppelin',
      album: 'Led Zeppelin IV',
    ),
    Track(
      id: '3',
      title: 'Hotel California',
      artist: 'Eagles',
      album: 'Hotel California',
    ),
    Track(
      id: '4',
      title: 'Imagine',
      artist: 'John Lennon',
      album: 'Imagine',
    ),
    Track(
      id: '5',
      title: 'Smells Like Teen Spirit',
      artist: 'Nirvana',
      album: 'Nevermind',
    ),
    Track(
      id: '6',
      title: 'Billie Jean',
      artist: 'Michael Jackson',
      album: 'Thriller',
    ),
  ];

  static const _albums = [
    Album(id: 'a1', title: 'Abbey Road', artist: 'The Beatles'),
    Album(id: 'a2', title: 'Dark Side of the Moon', artist: 'Pink Floyd'),
    Album(id: 'a3', title: 'Back in Black', artist: 'AC/DC'),
    Album(id: 'a4', title: 'Rumours', artist: 'Fleetwood Mac'),
    Album(id: 'a5', title: 'The Wall', artist: 'Pink Floyd'),
    Album(id: 'a6', title: 'Thriller', artist: 'Michael Jackson'),
  ];

  static const _artists = [
    Artist(id: 'ar1', name: 'The Beatles'),
    Artist(id: 'ar2', name: 'Pink Floyd'),
    Artist(id: 'ar3', name: 'Queen'),
    Artist(id: 'ar4', name: 'Led Zeppelin'),
    Artist(id: 'ar5', name: 'Nirvana'),
    Artist(id: 'ar6', name: 'David Bowie'),
  ];

  static const _playlists = [
    Playlist(id: 'p1', name: 'Избранное', trackCount: 42),
    Playlist(id: 'p2', name: 'Для работы', trackCount: 28),
    Playlist(id: 'p3', name: 'Вечерний джаз', trackCount: 15),
    Playlist(id: 'p4', name: 'Дорога', trackCount: 33),
    Playlist(id: 'p5', name: 'Классика рока', trackCount: 50),
  ];

  static HomeSections get homeSections => HomeSections(
        recentlyPlayed: _tracks,
        recentlyAdded: _albums,
        favoriteAlbums: _albums,
        favoriteArtists: _artists,
      );

  static PlayerUiState get initialPlayerState => PlayerUiState(
        currentTrack: _tracks.first,
        queue: _tracks,
        isPlaying: true,
      );

  static List<Artist> get artists => _artists;

  static List<Album> get albums => _albums;

  static List<Playlist> get playlists => _playlists;
}
