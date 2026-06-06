import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/models/track.dart';

abstract final class MockData {
  static const _artists = [
    Artist(id: 'ar1', name: 'The Beatles'),
    Artist(id: 'ar2', name: 'Pink Floyd'),
    Artist(id: 'ar3', name: 'Queen'),
    Artist(id: 'ar4', name: 'Led Zeppelin'),
    Artist(id: 'ar5', name: 'Nirvana'),
    Artist(id: 'ar6', name: 'David Bowie'),
    Artist(id: 'ar7', name: 'Eagles'),
    Artist(id: 'ar8', name: 'John Lennon'),
    Artist(id: 'ar9', name: 'Michael Jackson'),
    Artist(id: 'ar10', name: 'AC/DC'),
    Artist(id: 'ar11', name: 'Fleetwood Mac'),
  ];

  static const _albums = [
    Album(
      id: 'a1',
      title: 'Abbey Road',
      artist: 'The Beatles',
      artistId: 'ar1',
      year: 1969,
    ),
    Album(
      id: 'a2',
      title: 'Dark Side of the Moon',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      year: 1973,
    ),
    Album(
      id: 'a3',
      title: 'Back in Black',
      artist: 'AC/DC',
      artistId: 'ar10',
      year: 1980,
    ),
    Album(
      id: 'a4',
      title: 'Rumours',
      artist: 'Fleetwood Mac',
      artistId: 'ar11',
      year: 1977,
    ),
    Album(
      id: 'a5',
      title: 'The Wall',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      year: 1979,
    ),
    Album(
      id: 'a6',
      title: 'Thriller',
      artist: 'Michael Jackson',
      artistId: 'ar9',
      year: 1982,
    ),
    Album(
      id: 'a7',
      title: 'A Night at the Opera',
      artist: 'Queen',
      artistId: 'ar3',
      year: 1975,
    ),
    Album(
      id: 'a8',
      title: 'Led Zeppelin IV',
      artist: 'Led Zeppelin',
      artistId: 'ar4',
      year: 1971,
    ),
    Album(
      id: 'a9',
      title: 'Hotel California',
      artist: 'Eagles',
      artistId: 'ar7',
      year: 1976,
    ),
    Album(
      id: 'a10',
      title: 'Imagine',
      artist: 'John Lennon',
      artistId: 'ar8',
      year: 1971,
    ),
    Album(
      id: 'a11',
      title: 'Nevermind',
      artist: 'Nirvana',
      artistId: 'ar5',
      year: 1991,
    ),
  ];

  static const _tracks = [
    Track(
      id: '1',
      filePath: '/mock/1.mp3',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      artistId: 'ar3',
      albumId: 'a7',
      album: 'A Night at the Opera',
      year: 1975,
      duration: Duration(minutes: 5, seconds: 55),
      trackNumber: 11,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '2',
      filePath: '/mock/2.mp3',
      title: 'Stairway to Heaven',
      artist: 'Led Zeppelin',
      artistId: 'ar4',
      albumId: 'a8',
      album: 'Led Zeppelin IV',
      year: 1971,
      duration: Duration(minutes: 8, seconds: 2),
      trackNumber: 4,
      genre: 'Hard Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '3',
      filePath: '/mock/3.mp3',
      title: 'Hotel California',
      artist: 'Eagles',
      artistId: 'ar7',
      albumId: 'a9',
      album: 'Hotel California',
      year: 1976,
      duration: Duration(minutes: 6, seconds: 30),
      trackNumber: 1,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '4',
      filePath: '/mock/4.mp3',
      title: 'Imagine',
      artist: 'John Lennon',
      artistId: 'ar8',
      albumId: 'a10',
      album: 'Imagine',
      year: 1971,
      duration: Duration(minutes: 3, seconds: 3),
      trackNumber: 1,
      genre: 'Pop Rock',
      format: 'MP3',
      bitrate: 320,
    ),
    Track(
      id: '5',
      filePath: '/mock/5.mp3',
      title: 'Smells Like Teen Spirit',
      artist: 'Nirvana',
      artistId: 'ar5',
      albumId: 'a11',
      album: 'Nevermind',
      year: 1991,
      duration: Duration(minutes: 5, seconds: 1),
      trackNumber: 1,
      genre: 'Grunge',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '6',
      filePath: '/mock/6.mp3',
      title: 'Billie Jean',
      artist: 'Michael Jackson',
      artistId: 'ar9',
      albumId: 'a6',
      album: 'Thriller',
      year: 1982,
      duration: Duration(minutes: 4, seconds: 54),
      trackNumber: 6,
      genre: 'Pop',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '7',
      filePath: '/mock/7.mp3',
      title: 'Come Together',
      artist: 'The Beatles',
      artistId: 'ar1',
      albumId: 'a1',
      album: 'Abbey Road',
      year: 1969,
      duration: Duration(minutes: 4, seconds: 20),
      trackNumber: 1,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '8',
      filePath: '/mock/8.mp3',
      title: 'Something',
      artist: 'The Beatles',
      artistId: 'ar1',
      albumId: 'a1',
      album: 'Abbey Road',
      year: 1969,
      duration: Duration(minutes: 3, seconds: 3),
      trackNumber: 3,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '9',
      filePath: '/mock/9.mp3',
      title: 'Here Comes the Sun',
      artist: 'The Beatles',
      artistId: 'ar1',
      albumId: 'a1',
      album: 'Abbey Road',
      year: 1969,
      duration: Duration(minutes: 3, seconds: 5),
      trackNumber: 7,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '10',
      filePath: '/mock/10.mp3',
      title: 'Speak to Me',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      albumId: 'a2',
      album: 'Dark Side of the Moon',
      year: 1973,
      duration: Duration(minutes: 1, seconds: 30),
      trackNumber: 1,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '11',
      filePath: '/mock/11.mp3',
      title: 'Time',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      albumId: 'a2',
      album: 'Dark Side of the Moon',
      year: 1973,
      duration: Duration(minutes: 6, seconds: 53),
      trackNumber: 4,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '12',
      filePath: '/mock/12.mp3',
      title: 'Money',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      albumId: 'a2',
      album: 'Dark Side of the Moon',
      year: 1973,
      duration: Duration(minutes: 6, seconds: 22),
      trackNumber: 6,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '13',
      filePath: '/mock/13.mp3',
      title: 'Hells Bells',
      artist: 'AC/DC',
      artistId: 'ar10',
      albumId: 'a3',
      album: 'Back in Black',
      year: 1980,
      duration: Duration(minutes: 5, seconds: 12),
      trackNumber: 1,
      genre: 'Hard Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '14',
      filePath: '/mock/14.mp3',
      title: 'Back in Black',
      artist: 'AC/DC',
      artistId: 'ar10',
      albumId: 'a3',
      album: 'Back in Black',
      year: 1980,
      duration: Duration(minutes: 4, seconds: 15),
      trackNumber: 4,
      genre: 'Hard Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '15',
      filePath: '/mock/15.mp3',
      title: 'Go Your Own Way',
      artist: 'Fleetwood Mac',
      artistId: 'ar11',
      albumId: 'a4',
      album: 'Rumours',
      year: 1977,
      duration: Duration(minutes: 3, seconds: 38),
      trackNumber: 5,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '16',
      filePath: '/mock/16.mp3',
      title: 'Dreams',
      artist: 'Fleetwood Mac',
      artistId: 'ar11',
      albumId: 'a4',
      album: 'Rumours',
      year: 1977,
      duration: Duration(minutes: 4, seconds: 14),
      trackNumber: 2,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '17',
      filePath: '/mock/17.mp3',
      title: 'Another Brick in the Wall, Pt. 2',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      albumId: 'a5',
      album: 'The Wall',
      year: 1979,
      duration: Duration(minutes: 3, seconds: 59),
      trackNumber: 5,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '18',
      filePath: '/mock/18.mp3',
      title: 'Comfortably Numb',
      artist: 'Pink Floyd',
      artistId: 'ar2',
      albumId: 'a5',
      album: 'The Wall',
      year: 1979,
      duration: Duration(minutes: 6, seconds: 23),
      trackNumber: 13,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '19',
      filePath: '/mock/19.mp3',
      title: 'Beat It',
      artist: 'Michael Jackson',
      artistId: 'ar9',
      albumId: 'a6',
      album: 'Thriller',
      year: 1982,
      duration: Duration(minutes: 4, seconds: 18),
      trackNumber: 4,
      genre: 'Pop',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '20',
      filePath: '/mock/20.mp3',
      title: 'Thriller',
      artist: 'Michael Jackson',
      artistId: 'ar9',
      albumId: 'a6',
      album: 'Thriller',
      year: 1982,
      duration: Duration(minutes: 5, seconds: 57),
      trackNumber: 7,
      genre: 'Pop',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '21',
      filePath: '/mock/21.mp3',
      title: 'Love of My Life',
      artist: 'Queen',
      artistId: 'ar3',
      albumId: 'a7',
      album: 'A Night at the Opera',
      year: 1975,
      duration: Duration(minutes: 3, seconds: 38),
      trackNumber: 9,
      genre: 'Progressive Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '22',
      filePath: '/mock/22.mp3',
      title: 'Black Dog',
      artist: 'Led Zeppelin',
      artistId: 'ar4',
      albumId: 'a8',
      album: 'Led Zeppelin IV',
      year: 1971,
      duration: Duration(minutes: 4, seconds: 55),
      trackNumber: 1,
      genre: 'Hard Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '23',
      filePath: '/mock/23.mp3',
      title: 'New Kid in Town',
      artist: 'Eagles',
      artistId: 'ar7',
      albumId: 'a9',
      album: 'Hotel California',
      year: 1976,
      duration: Duration(minutes: 5, seconds: 4),
      trackNumber: 2,
      genre: 'Rock',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '24',
      filePath: '/mock/24.mp3',
      title: 'Gimme Shelter',
      artist: 'John Lennon',
      artistId: 'ar8',
      albumId: 'a10',
      album: 'Imagine',
      year: 1971,
      duration: Duration(minutes: 4, seconds: 31),
      trackNumber: 2,
      genre: 'Pop Rock',
      format: 'MP3',
      bitrate: 320,
    ),
    Track(
      id: '25',
      filePath: '/mock/25.mp3',
      title: 'In Bloom',
      artist: 'Nirvana',
      artistId: 'ar5',
      albumId: 'a11',
      album: 'Nevermind',
      year: 1991,
      duration: Duration(minutes: 4, seconds: 14),
      trackNumber: 2,
      genre: 'Grunge',
      format: 'FLAC',
      bitrate: 1411,
    ),
    Track(
      id: '26',
      filePath: '/mock/26.mp3',
      title: 'Come As You Are',
      artist: 'Nirvana',
      artistId: 'ar5',
      albumId: 'a11',
      album: 'Nevermind',
      year: 1991,
      duration: Duration(minutes: 3, seconds: 39),
      trackNumber: 3,
      genre: 'Grunge',
      format: 'FLAC',
      bitrate: 1411,
    ),
  ];

  static const _playlists = [
    Playlist(id: 'p1', name: 'Избранное', trackCount: 42),
    Playlist(id: 'p2', name: 'Для работы', trackCount: 28),
    Playlist(id: 'p3', name: 'Вечерний джаз', trackCount: 15),
    Playlist(id: 'p4', name: 'Дорога', trackCount: 33),
    Playlist(id: 'p5', name: 'Классика рока', trackCount: 50),
  ];

  static HomeSections get homeSections => HomeSections(
        recentlyPlayed: _tracks.take(6).toList(),
        recentlyAdded: _albums,
        favoriteAlbums: _albums,
        favoriteArtists: _artists.take(6).toList(),
      );

  static List<Artist> get artists => _artists;

  static List<Album> get albums => _albums;

  static List<Playlist> get playlists => _playlists;

  static List<Track> get tracks => _tracks;

  static Artist? artistById(String id) {
    for (final artist in _artists) {
      if (artist.id == id) return artist;
    }
    return null;
  }

  static Album? albumById(String id) {
    for (final album in _albums) {
      if (album.id == id) return album;
    }
    return null;
  }

  static Track? trackById(String id) {
    for (final track in _tracks) {
      if (track.id == id) return track;
    }
    return null;
  }

  static List<Album> albumsForArtist(String artistId) {
    return _albums.where((album) => album.artistId == artistId).toList();
  }

  static List<Track> tracksForAlbum(String albumId) {
    final tracks =
        _tracks.where((track) => track.albumId == albumId).toList();
    tracks.sort(
      (a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0),
    );
    return tracks;
  }

  static List<Track> tracksForArtist(String artistId) {
    return _tracks.where((track) => track.artistId == artistId).toList();
  }

  static List<Album> otherAlbumsByArtist(
    String artistId, {
    required String excludeAlbumId,
  }) {
    return _albums
        .where(
          (album) =>
              album.artistId == artistId && album.id != excludeAlbumId,
        )
        .toList();
  }
}
