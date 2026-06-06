import 'package:metadata_god/metadata_god.dart';

import 'package:music_player/services/scanner/metadata_god_bootstrap.dart';

import 'package:music_player/services/scanner/raw_track_metadata.dart';

class MetadataExtractor {
  Future<RawTrackMetadata> extract(String filePath) async {
    ensureMetadataGodInitialized();
    final metadata = await MetadataGod.readMetadata(file: filePath);

    return RawTrackMetadata(
      title: _nonEmpty(metadata.title),
      artist: _nonEmpty(metadata.artist) ?? _nonEmpty(metadata.albumArtist),
      album: _nonEmpty(metadata.album),
      durationMs: metadata.durationMs?.floor() ?? 0,
      trackNumber: metadata.trackNumber,
      genre: _nonEmpty(metadata.genre),
      year: metadata.year,
      embeddedCoverBytes: metadata.picture?.data,
      embeddedCoverMimeType: metadata.picture?.mimeType,
    );
  }

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
