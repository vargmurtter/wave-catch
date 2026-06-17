import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:music_player/app_paths.dart';
import 'package:music_player/repositories/ytdlp_auth_settings.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';

class AppSettingsRepository {
  static const _configFileName = 'app_config.json';
  static const _musicLibraryPathKey = 'musicLibraryPath';
  static const _albumGroupingStrategyKey = 'albumGroupingStrategy';
  static const _metadataEditModeKey = 'metadataEditMode';
  static const _lastFmApiKeyKey = 'lastFmApiKey';
  static const _languageCodeKey = 'languageCode';
  static const _ytdlpCookieSourceKey = 'ytdlpCookieSource';
  static const _ytdlpCookiesFilePathKey = 'ytdlpCookiesFilePath';
  static const _ytdlpBrowserKey = 'ytdlpBrowser';

  Future<File> _configFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(supportDir.path, kAppDataDirName));
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

  Future<String?> getLanguageCode() async {
    final config = await _readConfig();
    final code = config[_languageCodeKey] as String?;
    if (code == null || code.trim().isEmpty) return null;
    return code.trim();
  }

  Future<String?> getLastFmApiKey() async {
    final config = await _readConfig();
    final key = config[_lastFmApiKeyKey] as String?;
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  Future<YtdlpAuthSettings> getYtdlpAuthSettings() async {
    final config = await _readConfig();
    final source = YtdlpCookieSource.fromJson(
      config[_ytdlpCookieSourceKey] as String?,
    );
    final cookiesPath = config[_ytdlpCookiesFilePathKey] as String?;
    final browser = config[_ytdlpBrowserKey] as String?;
    return YtdlpAuthSettings(
      source: source,
      cookiesFilePath:
          cookiesPath == null || cookiesPath.trim().isEmpty
              ? null
              : cookiesPath.trim(),
      browser:
          browser == null || browser.trim().isEmpty
              ? 'chrome'
              : browser.trim(),
    );
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

  Future<void> setLanguageCode(String? code) async {
    final config = await _readConfig();
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      config.remove(_languageCodeKey);
    } else {
      config[_languageCodeKey] = trimmed;
    }
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

  Future<void> setYtdlpAuthSettings(YtdlpAuthSettings settings) async {
    final config = await _readConfig();
    if (settings.source == YtdlpCookieSource.none) {
      config.remove(_ytdlpCookieSourceKey);
    } else {
      config[_ytdlpCookieSourceKey] = settings.source.toJson();
    }

    final cookiesPath = settings.cookiesFilePath?.trim();
    if (cookiesPath == null || cookiesPath.isEmpty) {
      config.remove(_ytdlpCookiesFilePathKey);
    } else {
      config[_ytdlpCookiesFilePathKey] = cookiesPath;
    }

    final browser = settings.browser.trim();
    if (browser.isEmpty || browser == 'chrome') {
      config.remove(_ytdlpBrowserKey);
    } else {
      config[_ytdlpBrowserKey] = browser;
    }

    await _writeConfig(config);
  }
}
