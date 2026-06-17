import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:music_player/app_paths.dart';

enum YtdlpBinarySource {
  cached,
  bundled,
  system,
}

class YtdlpBinaryInfo {
  const YtdlpBinaryInfo({
    required this.path,
    required this.source,
    this.version,
  });

  final String path;
  final YtdlpBinarySource source;
  final String? version;
}

class YtdlpNotFoundException implements Exception {
  YtdlpNotFoundException([this.message = 'yt-dlp binary not found']);

  final String message;

  @override
  String toString() => message;
}

class YtdlpBinaryResolver {
  YtdlpBinaryResolver();

  YtdlpBinaryInfo? _cachedInfo;

  Future<YtdlpBinaryInfo> resolve() async {
    if (_cachedInfo != null) {
      final file = File(_cachedInfo!.path);
      if (file.existsSync()) return _cachedInfo!;
    }

    final appSupportBin = await _appSupportBinaryPath();
    if (await _isExecutable(appSupportBin)) {
      final version = await _readVersion(appSupportBin);
      _cachedInfo = YtdlpBinaryInfo(
        path: appSupportBin,
        source: YtdlpBinarySource.cached,
        version: version,
      );
      return _cachedInfo!;
    }

    final bundled = await _materializeBundledBinary(appSupportBin);
    if (bundled != null) {
      _cachedInfo = bundled;
      return bundled;
    }

    final system = await _findSystemBinary();
    if (system != null) {
      _cachedInfo = system;
      return system;
    }

    throw YtdlpNotFoundException();
  }

  Future<bool> isAvailable() async {
    try {
      await resolve();
      return true;
    } on YtdlpNotFoundException {
      return false;
    }
  }

  Future<String?> getVersion() async {
    try {
      final info = await resolve();
      return info.version ?? await _readVersion(info.path);
    } on YtdlpNotFoundException {
      return null;
    }
  }

  Future<YtdlpBinaryInfo?> _materializeBundledBinary(String targetPath) async {
    final assetPath = _bundledAssetPath();
    if (assetPath == null) return null;

    try {
      final bytes = await rootBundle.load(assetPath);
      final dir = Directory(p.dirname(targetPath));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File(targetPath);
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', targetPath]);
      }
      final version = await _readVersion(targetPath);
      return YtdlpBinaryInfo(
        path: targetPath,
        source: YtdlpBinarySource.bundled,
        version: version,
      );
    } on Object {
      return null;
    }
  }

  String? _bundledAssetPath() {
    if (Platform.isMacOS) {
      return 'assets/bin/macos/yt-dlp';
    }
    if (Platform.isLinux) {
      return 'assets/bin/linux/yt-dlp';
    }
    if (Platform.isWindows) {
      return 'assets/bin/windows/yt-dlp.exe';
    }
    return null;
  }

  Future<String> _appSupportBinaryPath() async {
    final support = await getApplicationSupportDirectory();
    final name = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';
    return p.join(support.path, kAppDataDirName, 'bin', name);
  }

  Future<YtdlpBinaryInfo?> _findSystemBinary() async {
    final candidates = <String>[];

    if (Platform.isMacOS) {
      candidates.addAll([
        '/opt/homebrew/bin/yt-dlp',
        '/usr/local/bin/yt-dlp',
        p.join(
          Platform.environment['HOME'] ?? '',
          '.local',
          'bin',
          'yt-dlp',
        ),
      ]);
    }

    final pathEnv = Platform.environment['PATH'];
    if (pathEnv != null) {
      final name = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';
      for (final segment in pathEnv.split(Platform.pathSeparator)) {
        if (segment.trim().isEmpty) continue;
        candidates.add(p.join(segment, name));
      }
    }

    for (final candidate in candidates) {
      if (candidate.isEmpty) continue;
      if (await _isExecutable(candidate)) {
        final version = await _readVersion(candidate);
        return YtdlpBinaryInfo(
          path: candidate,
          source: YtdlpBinarySource.system,
          version: version,
        );
      }
    }
    return null;
  }

  Future<bool> _isExecutable(String path) async {
    final file = File(path);
    if (!file.existsSync()) return false;
    try {
      final result = await Process.run(
        path,
        ['--version'],
        runInShell: Platform.isWindows,
      ).timeout(const Duration(seconds: 8));
      return result.exitCode == 0;
    } on Object {
      return false;
    }
  }

  Future<String?> _readVersion(String path) async {
    try {
      final result = await Process.run(
        path,
        ['--version'],
        runInShell: Platform.isWindows,
      ).timeout(const Duration(seconds: 8));
      if (result.exitCode != 0) return null;
      final text = (result.stdout as String).trim();
      return text.split('\n').first.trim();
    } on Object {
      return null;
    }
  }
}
