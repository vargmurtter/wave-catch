import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/models/playback_mode.dart';
import 'package:music_player/ui/models/track.dart';

sealed class PlayableItem {
  const PlayableItem();

  String get id;
  String get title;
  String get artist;
  String? get thumbnailUrl;
  Duration get duration;
  PlaybackMode get playbackMode;

  Track? get libraryTrack => null;
  ExploreTrack? get exploreTrack => null;
}

final class LocalPlayableItem extends PlayableItem {
  const LocalPlayableItem(this.track);

  final Track track;

  @override
  String get id => track.id;

  @override
  String get title => track.title;

  @override
  String get artist => track.artist;

  @override
  String? get thumbnailUrl => null;

  @override
  Duration get duration => track.duration;

  @override
  PlaybackMode get playbackMode => PlaybackMode.library;

  @override
  Track? get libraryTrack => track;
}

final class RemotePlayableItem extends PlayableItem {
  const RemotePlayableItem(this.track);

  final ExploreTrack track;

  @override
  String get id => track.videoId;

  @override
  String get title => track.title;

  @override
  String get artist => track.artist;

  @override
  String? get thumbnailUrl => track.thumbnailUrl;

  @override
  Duration get duration => track.duration;

  @override
  PlaybackMode get playbackMode => PlaybackMode.explore;

  @override
  ExploreTrack? get exploreTrack => track;
}

extension PlayableItemListX on List<PlayableItem> {
  List<Track> get libraryTracksOnly =>
      map((item) => item.libraryTrack).whereType<Track>().toList();
}
