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
    this.embeddedCoverBytes,
    this.embeddedCoverMimeType,
  });

  final String? title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final int durationMs;
  final int? trackNumber;
  final String? genre;
  final int? year;
  final Uint8List? embeddedCoverBytes;
  final String? embeddedCoverMimeType;
}
