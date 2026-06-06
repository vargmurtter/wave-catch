import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/track.dart';

class LibrarySearchResults {
  const LibrarySearchResults({
    this.artists = const [],
    this.albums = const [],
    this.tracks = const [],
  });

  final List<Artist> artists;
  final List<Album> albums;
  final List<Track> tracks;

  static const empty = LibrarySearchResults();

  bool get isEmpty =>
      artists.isEmpty && albums.isEmpty && tracks.isEmpty;
}
