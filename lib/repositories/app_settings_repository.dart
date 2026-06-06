import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppSettingsRepository {
  static const _configFileName = 'app_config.json';

  Future<File> _configFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(supportDir.path, 'music_player'));
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return File(p.join(appDir.path, _configFileName));
  }

  Future<String?> getMusicLibraryPath() async {
    final file = await _configFile();
    if (!file.existsSync()) return null;

    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['musicLibraryPath'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setMusicLibraryPath(String path) async {
    final file = await _configFile();
    await file.writeAsString(
      jsonEncode({'musicLibraryPath': path}),
    );
  }
}
