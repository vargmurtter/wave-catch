import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/ui/models/track.dart';

class TrackMetadataEdit {
  const TrackMetadataEdit({
    required this.title,
    required this.artist,
    required this.featuredArtists,
    this.albumArtist,
    required this.album,
    this.year,
    this.genre,
    this.trackNumber,
    this.discNumber,
    this.newCoverImagePath,
  });

  final String title;
  final String artist;
  final List<String> featuredArtists;
  final String? albumArtist;
  final String album;
  final int? year;
  final String? genre;
  final int? trackNumber;
  final int? discNumber;
  final String? newCoverImagePath;

  factory TrackMetadataEdit.fromTrack(Track track) {
    return TrackMetadataEdit(
      title: track.title,
      artist: track.artist,
      featuredArtists: track.featuredArtists,
      albumArtist: track.albumArtist,
      album: track.album ?? '',
      year: track.year,
      genre: track.genre,
      trackNumber: track.trackNumber,
      discNumber: track.discNumber,
    );
  }

  TrackMetadataOverride toOverride({
    required String? coverPath,
    required int updatedAtMs,
  }) {
    return TrackMetadataOverride(
      title: title,
      artist: artist,
      featuredArtists: featuredArtists,
      albumArtist: albumArtist,
      album: album,
      year: year,
      genre: genre,
      trackNumber: trackNumber,
      discNumber: discNumber,
      coverPath: coverPath,
      updatedAtMs: updatedAtMs,
    );
  }
}

class TrackMetadataEditResult {
  const TrackMetadataEditResult({required this.track});

  final Track track;
}

class MetadataEditException implements Exception {
  MetadataEditException(this.message);

  final String message;

  @override
  String toString() => message;
}
