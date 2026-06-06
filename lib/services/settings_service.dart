import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

import 'package:music_player/repositories/app_settings_repository.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';

class SettingsService {
  SettingsService(this._appSettingsRepository);

  final AppSettingsRepository _appSettingsRepository;

  String? _musicLibraryPath;
  AlbumGroupingStrategy _albumGroupingStrategy =
      AlbumGroupingStrategy.byAlbumArtist;

  String? get musicLibraryPath => _musicLibraryPath;

  AlbumGroupingStrategy get albumGroupingStrategy => _albumGroupingStrategy;

  bool get isLibraryConfigured {
    final path = _musicLibraryPath;
    return path != null && Directory(path).existsSync();
  }

  Future<void> load() async {
    _musicLibraryPath = await _appSettingsRepository.getMusicLibraryPath();
    _albumGroupingStrategy =
        await _appSettingsRepository.getAlbumGroupingStrategy();
  }

  Future<String?> pickMusicFolder() async {
    await _focusAppWindow();

    return FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Выберите папку с музыкой',
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
}
