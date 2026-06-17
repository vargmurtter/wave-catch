import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/track.dart';

class HomeSections {
  const HomeSections({
    required this.recentlyPlayed,
    required this.recentlyAdded,
    required this.favoriteAlbums,
    required this.favoriteArtists,
  });

  final List<Track> recentlyPlayed;
  final List<Track> recentlyAdded;
  final List<Album> favoriteAlbums;
  final List<Artist> favoriteArtists;
}
