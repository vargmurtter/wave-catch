import 'dart:typed_data';

class RawTrackMetadata {
  const RawTrackMetadata({
    this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.durationMs = 0,
    this.trackNumber,
    this.genre,
    this.year,
    this.discNumber,
    this.featuredArtists = const [],
    this.embeddedCoverBytes,
    this.embeddedCoverMimeType,
    this.overrideCoverPath,
  });

  final String? title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final int durationMs;
  final int? trackNumber;
  final String? genre;
  final int? year;
  final int? discNumber;
  final List<String> featuredArtists;
  final Uint8List? embeddedCoverBytes;
  final String? embeddedCoverMimeType;
  final String? overrideCoverPath;

  RawTrackMetadata copyWith({
    String? title,
    String? artist,
    String? albumArtist,
    String? album,
    int? durationMs,
    int? trackNumber,
    String? genre,
    int? year,
    int? discNumber,
    List<String>? featuredArtists,
    Uint8List? embeddedCoverBytes,
    String? embeddedCoverMimeType,
    String? overrideCoverPath,
  }) {
    return RawTrackMetadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtist: albumArtist ?? this.albumArtist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      trackNumber: trackNumber ?? this.trackNumber,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      discNumber: discNumber ?? this.discNumber,
      featuredArtists: featuredArtists ?? this.featuredArtists,
      embeddedCoverBytes: embeddedCoverBytes ?? this.embeddedCoverBytes,
      embeddedCoverMimeType:
          embeddedCoverMimeType ?? this.embeddedCoverMimeType,
      overrideCoverPath: overrideCoverPath ?? this.overrideCoverPath,
    );
  }
}
