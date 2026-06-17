import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

import 'package:music_player/l10n/app_locale.dart';
import 'package:music_player/repositories/app_settings_repository.dart';
import 'package:music_player/repositories/ytdlp_auth_settings.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';

class SettingsService {
  SettingsService(this._appSettingsRepository);

  final AppSettingsRepository _appSettingsRepository;

  String? _musicLibraryPath;
  AlbumGroupingStrategy _albumGroupingStrategy =
      AlbumGroupingStrategy.byAlbumArtist;
  MetadataEditMode _metadataEditMode = MetadataEditMode.override;
  String? _lastFmApiKey;
  AppLanguage? _language;
  YtdlpAuthSettings _ytdlpAuthSettings = const YtdlpAuthSettings();

  String? get musicLibraryPath => _musicLibraryPath;

  AlbumGroupingStrategy get albumGroupingStrategy => _albumGroupingStrategy;

  MetadataEditMode get metadataEditMode => _metadataEditMode;

  String? get lastFmApiKey => _lastFmApiKey;

  AppLanguage? get language => _language;

  bool get hasLanguageSelected => _language != null;

  YtdlpAuthSettings get ytdlpAuthSettings => _ytdlpAuthSettings;

  bool get isLibraryConfigured {
    final path = _musicLibraryPath;
    return path != null && Directory(path).existsSync();
  }

  Future<void> load() async {
    _musicLibraryPath = await _appSettingsRepository.getMusicLibraryPath();
    _albumGroupingStrategy =
        await _appSettingsRepository.getAlbumGroupingStrategy();
    _metadataEditMode = await _appSettingsRepository.getMetadataEditMode();
    _lastFmApiKey = await _appSettingsRepository.getLastFmApiKey();
    _language = AppLanguage.fromCode(
      await _appSettingsRepository.getLanguageCode(),
    );
    _ytdlpAuthSettings = await _appSettingsRepository.getYtdlpAuthSettings();
  }

  Future<String?> pickMusicFolder({required String dialogTitle}) async {
    await _focusAppWindow();

    return FilePicker.platform.getDirectoryPath(
      dialogTitle: dialogTitle,
    );
  }

  Future<void> _focusAppWindow() async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) return;

    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {
      // window_manager may not be ready yet; picker can still work.
    }
  }

  Future<void> setMusicLibraryPath(String path) async {
    _musicLibraryPath = path;
    await _appSettingsRepository.setMusicLibraryPath(path);
  }

  Future<void> setAlbumGroupingStrategy(AlbumGroupingStrategy strategy) async {
    _albumGroupingStrategy = strategy;
    await _appSettingsRepository.setAlbumGroupingStrategy(strategy);
  }

  Future<void> setMetadataEditMode(MetadataEditMode mode) async {
    _metadataEditMode = mode;
    await _appSettingsRepository.setMetadataEditMode(mode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await _appSettingsRepository.setLanguageCode(language.code);
  }

  Future<void> setLastFmApiKey(String? key) async {
    final trimmed = key?.trim();
    _lastFmApiKey =
        trimmed == null || trimmed.isEmpty ? null : trimmed;
    await _appSettingsRepository.setLastFmApiKey(_lastFmApiKey);
  }

  Future<String?> pickCookiesFile({required String dialogTitle}) async {
    await _focusAppWindow();

    return FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: ['txt'],
    ).then((result) {
      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return null;
      return path;
    });
  }

  Future<void> setYtdlpAuthSettings(YtdlpAuthSettings settings) async {
    _ytdlpAuthSettings = settings;
    await _appSettingsRepository.setYtdlpAuthSettings(settings);
  }
}
