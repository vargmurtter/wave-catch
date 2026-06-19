import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:music_player/app_paths.dart';

enum YtdlpBinarySource {
  bundled,
  fallback,
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

/// Filesystem path to the bundled yt-dlp binary relative to [resolvedExecutable].
///
/// Platform flags are optional and default to [Platform]; pass them explicitly in
/// tests so paths can be verified on any host OS.
String bundledYtdlpPath(
  String resolvedExecutable, {
  bool? isMacOS,
  bool? isLinux,
  bool? isWindows,
}) {
  if (isMacOS == true || (isMacOS == null && isLinux != true && isWindows != true && Platform.isMacOS)) {
    return p.normalize(
      p.join(
        p.dirname(resolvedExecutable),
        '..',
        'Frameworks',
        'App.framework',
        'Versions',
        'A',
        'Resources',
        'flutter_assets',
        'assets',
        'bin',
        'macos',
        'yt-dlp',
      ),
    );
  }
  if (isLinux == true || (isLinux == null && isWindows != true && Platform.isLinux)) {
    return p.join(
      p.dirname(resolvedExecutable),
      'data',
      'flutter_assets',
      'assets',
      'bin',
      'linux',
      'yt-dlp',
    );
  }
  if (isWindows == true || (isWindows == null && Platform.isWindows)) {
    final normalized = resolvedExecutable.replaceAll('/', r'\');
    final parts = normalized.split(r'\')..removeLast();
    final exeDir = parts.join(r'\');
    return p.join(
      exeDir,
      'data',
      'flutter_assets',
      'assets',
      'bin',
      'windows',
      'yt-dlp.exe',
    );
  }
  throw UnsupportedError('Unsupported platform for bundled yt-dlp');
}

class YtdlpBinaryResolver {
  YtdlpBinaryResolver();

  /// Keep in sync with [scripts/fetch_ytdlp.sh].
  static const bundledYtdlpVersion = '2026.06.09';

  static const _versionCheckTimeout = Duration(seconds: 30);

  YtdlpBinaryInfo? _cachedInfo;

  Future<YtdlpBinaryInfo> resolve() async {
    if (_cachedInfo != null) {
      final file = File(_cachedInfo!.path);
      if (file.existsSync()) return _cachedInfo!;
    }

    final bundledPath = bundledYtdlpPath(Platform.resolvedExecutable);
    if (File(bundledPath).existsSync()) {
      if (Platform.isLinux && !await _isExecutable(bundledPath)) {
        final fallback = await _resolveLinuxFallback(bundledPath);
        if (fallback != null) {
          _cachedInfo = fallback;
          return fallback;
        }
      } else {
        _cachedInfo = YtdlpBinaryInfo(
          path: bundledPath,
          source: YtdlpBinarySource.bundled,
          version: bundledYtdlpVersion,
        );
        return _cachedInfo!;
      }
    }

    final system = await _findSystemBinary();
    if (system != null) {
      _cachedInfo = system;
      return system;
    }

    throw YtdlpNotFoundException();
  }

  Future<bool> isAvailable() async {
    final bundledPath = bundledYtdlpPath(Platform.resolvedExecutable);
    if (File(bundledPath).existsSync()) return true;

    try {
      return await _findSystemBinary() != null;
    } on Object {
      return false;
    }
  }

  Future<String?> getVersion() async {
    try {
      final info = await resolve();
      if (info.source == YtdlpBinarySource.bundled) {
        return bundledYtdlpVersion;
      }
      return info.version ?? await _readVersion(info.path);
    } on YtdlpNotFoundException {
      return null;
    }
  }

  Future<YtdlpBinaryInfo?> _resolveLinuxFallback(String bundledPath) async {
    await Process.run('chmod', ['+x', bundledPath]);
    if (await _isExecutable(bundledPath)) {
      return YtdlpBinaryInfo(
        path: bundledPath,
        source: YtdlpBinarySource.bundled,
        version: bundledYtdlpVersion,
      );
    }

    final targetPath = await _appSupportBinaryPath();
    try {
      final dir = Directory(p.dirname(targetPath));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      await File(bundledPath).copy(targetPath);
      await Process.run('chmod', ['+x', targetPath]);
      if (!await _isExecutable(targetPath)) return null;

      final version = await _readVersion(targetPath) ?? bundledYtdlpVersion;
      return YtdlpBinaryInfo(
        path: targetPath,
        source: YtdlpBinarySource.fallback,
        version: version,
      );
    } on Object {
      return null;
    }
  }

  Future<String> _appSupportBinaryPath() async {
    final support = await getApplicationSupportDirectory();
    return p.join(support.path, kAppDataDirName, 'bin', 'yt-dlp');
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
        environment: _subprocessEnvironment(),
        runInShell: Platform.isWindows,
      ).timeout(_versionCheckTimeout);
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
        environment: _subprocessEnvironment(),
        runInShell: Platform.isWindows,
      ).timeout(_versionCheckTimeout);
      if (result.exitCode != 0) return null;
      final text = (result.stdout as String).trim();
      return text.split('\n').first.trim();
    } on Object {
      return null;
    }
  }

  Map<String, String> _subprocessEnvironment() {
    final env = Map<String, String>.from(Platform.environment);
    final extras = <String>[
      if (Platform.isMacOS) ...['/opt/homebrew/bin', '/usr/local/bin'],
      if (Platform.isLinux) '/usr/local/bin',
      if (env['HOME'] != null) p.join(env['HOME']!, '.local', 'bin'),
    ];
    final segments = <String>{
      for (final segment in [
        ...extras,
        ...(env['PATH'] ?? '').split(Platform.pathSeparator),
      ])
        if (segment.trim().isNotEmpty) segment.trim(),
    };
    env['PATH'] = segments.join(Platform.pathSeparator);
    return env;
  }
}
