import 'package:metadata_god/metadata_god.dart';

import 'package:music_player/services/scanner/metadata_god_bootstrap.dart';
import 'package:music_player/services/scanner/raw_track_metadata.dart';
import 'package:music_player/services/scanner/tag_text_fixer.dart';

class MetadataExtractor {
  MetadataExtractor({TagTextFixer? tagTextFixer})
      : _tagTextFixer = tagTextFixer ?? const TagTextFixer();

  final TagTextFixer _tagTextFixer;

  Future<RawTrackMetadata> extract(String filePath) async {
    ensureMetadataGodInitialized();
    final metadata = await MetadataGod.readMetadata(file: filePath);

    return RawTrackMetadata(
      title: _fixText(_nonEmpty(metadata.title)),
      artist: _fixText(
        _nonEmpty(metadata.artist) ?? _nonEmpty(metadata.albumArtist),
      ),
      albumArtist: _fixText(_nonEmpty(metadata.albumArtist)),
      album: _fixText(_nonEmpty(metadata.album)),
      durationMs: metadata.durationMs?.floor() ?? 0,
      trackNumber: metadata.trackNumber,
      genre: _fixText(_nonEmpty(metadata.genre)),
      year: metadata.year,
      embeddedCoverBytes: metadata.picture?.data,
      embeddedCoverMimeType: metadata.picture?.mimeType,
    );
  }

  String? _fixText(String? value) => _tagTextFixer.fix(value);

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
