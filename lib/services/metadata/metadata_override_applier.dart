import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/services/scanner/raw_track_metadata.dart';

class MetadataOverrideApplier {
  RawTrackMetadata applyFull(
    RawTrackMetadata raw,
    TrackMetadataOverride? override,
  ) {
    if (override == null) return raw;
    return _applyFields(raw, override, full: true);
  }

  RawTrackMetadata applyFeaturedOnly(
    RawTrackMetadata raw,
    TrackMetadataOverride? override,
  ) {
    if (override == null || override.featuredArtists == null) return raw;
    return raw.copyWith(featuredArtists: override.featuredArtists);
  }

  RawTrackMetadata _applyFields(
    RawTrackMetadata raw,
    TrackMetadataOverride override, {
    required bool full,
  }) {
    var result = raw;

    if (full) {
      result = result.copyWith(
        title: override.title ?? raw.title,
        artist: override.artist ?? raw.artist,
        albumArtist: override.albumArtist ?? raw.albumArtist,
        album: override.album ?? raw.album,
        year: override.year ?? raw.year,
        genre: override.genre ?? raw.genre,
        trackNumber: override.trackNumber ?? raw.trackNumber,
        discNumber: override.discNumber ?? raw.discNumber,
        overrideCoverPath: override.coverPath,
      );
    }

    if (override.featuredArtists != null) {
      result = result.copyWith(featuredArtists: override.featuredArtists);
    }

    return result;
  }
}
