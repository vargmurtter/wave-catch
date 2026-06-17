class ExploreArtist {
  const ExploreArtist({required this.name, this.id});

  final String name;
  final String? id;
}

class ExploreTrack {
  const ExploreTrack({
    required this.videoId,
    required this.title,
    required this.artist,
    this.artistId,
    this.artists = const [],
    this.album,
    this.albumId,
    this.thumbnailUrl,
    this.duration = Duration.zero,
    this.year,
  });

  final String videoId;
  final String title;
  final String artist;
  final String? artistId;
  final List<ExploreArtist> artists;
  final String? album;
  final String? albumId;
  final String? thumbnailUrl;
  final Duration duration;
  final int? year;

  String get watchUrl => 'https://music.youtube.com/watch?v=$videoId';

  ExploreTrack copyWith({
    String? title,
    String? artist,
    String? artistId,
    List<ExploreArtist>? artists,
    String? album,
    String? albumId,
    String? thumbnailUrl,
    Duration? duration,
    int? year,
  }) {
    return ExploreTrack(
      videoId: videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      year: year ?? this.year,
    );
  }
}
