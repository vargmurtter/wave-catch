import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:music_player/services/scanner/album_grouping_strategy.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';

class AppSettingsRepository {
  static const _configFileName = 'app_config.json';
  static const _musicLibraryPathKey = 'musicLibraryPath';
  static const _albumGroupingStrategyKey = 'albumGroupingStrategy';
  static const _metadataEditModeKey = 'metadataEditMode';
  static const _lastFmApiKeyKey = 'lastFmApiKey';

  Future<File> _configFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(supportDir.path, 'music_player'));
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return File(p.join(appDir.path, _configFileName));
  }

  Future<Map<String, dynamic>> _readConfig() async {
    final file = await _configFile();
    if (!file.existsSync()) return {};

    try {
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) return json;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeConfig(Map<String, dynamic> config) async {
    final file = await _configFile();
    await file.writeAsString(jsonEncode(config));
  }

  Future<String?> getMusicLibraryPath() async {
    final config = await _readConfig();
    return config[_musicLibraryPathKey] as String?;
  }

  Future<AlbumGroupingStrategy> getAlbumGroupingStrategy() async {
    final config = await _readConfig();
    return AlbumGroupingStrategyLabels.fromJson(
      config[_albumGroupingStrategyKey] as String?,
    );
  }

  Future<MetadataEditMode> getMetadataEditMode() async {
    final config = await _readConfig();
    return MetadataEditModeLabels.fromJson(
      config[_metadataEditModeKey] as String?,
    );
  }

  Future<String?> getLastFmApiKey() async {
    final config = await _readConfig();
    final key = config[_lastFmApiKeyKey] as String?;
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  Future<void> setMusicLibraryPath(String path) async {
    final config = await _readConfig();
    config[_musicLibraryPathKey] = path;
    await _writeConfig(config);
  }

  Future<void> setAlbumGroupingStrategy(AlbumGroupingStrategy strategy) async {
    final config = await _readConfig();
    config[_albumGroupingStrategyKey] = strategy.toJson();
    await _writeConfig(config);
  }

  Future<void> setMetadataEditMode(MetadataEditMode mode) async {
    final config = await _readConfig();
    config[_metadataEditModeKey] = mode.toJson();
    await _writeConfig(config);
  }

  Future<void> setLastFmApiKey(String? key) async {
    final config = await _readConfig();
    final trimmed = key?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      config.remove(_lastFmApiKeyKey);
    } else {
      config[_lastFmApiKeyKey] = trimmed;
    }
    await _writeConfig(config);
  }
}
