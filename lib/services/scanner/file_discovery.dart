import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:music_player/services/scanner/scan_rules.dart';

class DiscoveredAudioFile {
  const DiscoveredAudioFile({
    required this.filePath,
    required this.parentDir,
    required this.fileNameWithoutExt,
  });

  final String filePath;
  final String parentDir;
  final String fileNameWithoutExt;
}

class FileDiscovery {
  List<DiscoveredAudioFile> discover(String musicRoot) {
    final rootDir = Directory(musicRoot);
    if (!rootDir.existsSync()) return [];

    final results = <DiscoveredAudioFile>[];
    _walk(rootDir, musicRoot, results);
    results.sort((a, b) => a.filePath.compareTo(b.filePath));
    return results;
  }

  void _walk(Directory dir, String musicRoot, List<DiscoveredAudioFile> results) {
    late final List<FileSystemEntity> entities;
    try {
      entities = dir.listSync(followLinks: false);
    } catch (_) {
      return;
    }

    for (final entity in entities) {
      if (entity is Directory) {
        final name = p.basename(entity.path);
        if (name == kAppDataDirName ||
            name == '.covers' ||
            name == '.music_player') {
          continue;
        }
        _walk(entity, musicRoot, results);
        continue;
      }

      if (entity is! File) continue;

      final fileName = p.basename(entity.path);
      if (fileName == kLibraryDbFileName) continue;

      final extension = p.extension(entity.path).replaceFirst('.', '').toLowerCase();
      if (!kAudioExtensions.contains(extension)) continue;

      results.add(
        DiscoveredAudioFile(
          filePath: entity.path,
          parentDir: p.dirname(entity.path),
          fileNameWithoutExt: p.basenameWithoutExtension(entity.path),
        ),
      );
    }
  }
}
