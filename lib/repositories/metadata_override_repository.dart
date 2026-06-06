import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/services/scanner/scan_rules.dart';

class MetadataOverrideRepository {
  File _overrideFile(String musicRoot) {
    final dir = Directory(p.join(musicRoot, kMetadataOverridesDir));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File(p.join(dir.path, kMetadataOverridesFileName));
  }

  Future<MetadataOverridesFile> loadAll(String musicRoot) async {
    final file = _overrideFile(musicRoot);
    if (!file.existsSync()) {
      return MetadataOverridesFile.empty();
    }

    try {
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        return MetadataOverridesFile.fromJson(json);
      }
    } catch (_) {}
    return MetadataOverridesFile.empty();
  }

  Future<TrackMetadataOverride?> getOverride(
    String musicRoot,
    String trackId,
  ) async {
    final file = await loadAll(musicRoot);
    return file.tracks[trackId];
  }

  Future<Map<String, TrackMetadataOverride>> loadTrackOverrides(
    String musicRoot,
  ) async {
    final file = await loadAll(musicRoot);
    return file.tracks;
  }

  Map<String, TrackMetadataOverride> loadTrackOverridesSync(String musicRoot) {
    final file = _overrideFile(musicRoot);
    if (!file.existsSync()) {
      return const {};
    }

    try {
      final json = jsonDecode(file.readAsStringSync());
      if (json is Map<String, dynamic>) {
        return MetadataOverridesFile.fromJson(json).tracks;
      }
    } catch (_) {}
    return const {};
  }

  Future<void> upsert(
    String musicRoot,
    String trackId,
    TrackMetadataOverride override,
  ) async {
    final file = await loadAll(musicRoot);
    final tracks = Map<String, TrackMetadataOverride>.from(file.tracks);
    tracks[trackId] = override;
    await _write(musicRoot, tracks);
  }

  Future<void> upsertFeaturedArtists(
    String musicRoot,
    String trackId,
    List<String> featuredArtists,
  ) async {
    final file = await loadAll(musicRoot);
    final tracks = Map<String, TrackMetadataOverride>.from(file.tracks);
    final existing = tracks[trackId];
    final updated = (existing ?? const TrackMetadataOverride()).copyWith(
      featuredArtists: featuredArtists,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (updated.isEmpty) {
      tracks.remove(trackId);
    } else {
      tracks[trackId] = updated;
    }
    await _write(musicRoot, tracks);
  }

  Future<void> remove(String musicRoot, String trackId) async {
    final file = await loadAll(musicRoot);
    final tracks = Map<String, TrackMetadataOverride>.from(file.tracks);
    tracks.remove(trackId);
    await _write(musicRoot, tracks);
  }

  Future<void> _write(
    String musicRoot,
    Map<String, TrackMetadataOverride> tracks,
  ) async {
    final payload = MetadataOverridesFile(version: 1, tracks: tracks);
    final file = _overrideFile(musicRoot);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload.toJson()),
    );
  }
}
