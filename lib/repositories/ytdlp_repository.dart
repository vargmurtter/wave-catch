import 'dart:async';
import 'dart:io';

import 'package:music_player/repositories/ytdlp_auth_settings.dart';
import 'package:music_player/repositories/ytdlp_binary_resolver.dart';

class YtdlpException implements Exception {
  YtdlpException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _CacheEntry {
  _CacheEntry(this.value, this.expiresAt);

  final String value;
  final DateTime expiresAt;
}

class YtdlpRepository {
  YtdlpRepository({
    YtdlpBinaryResolver? resolver,
    YtdlpAuthSettings Function()? authSettings,
  })  : _resolver = resolver ?? YtdlpBinaryResolver(),
        _authSettings = authSettings ?? (() => const YtdlpAuthSettings());

  final YtdlpBinaryResolver _resolver;
  final YtdlpAuthSettings Function() _authSettings;
  final Map<String, _CacheEntry> _streamCache = {};
  static const _cacheTtl = Duration(hours: 4);
  Process? _activeDownload;

  Future<YtdlpBinaryInfo> getBinaryInfo() => _resolver.resolve();

  Future<bool> isAvailable() => _resolver.isAvailable();

  Future<String?> getVersion() => _resolver.getVersion();

  Future<String> getStreamUrl(String watchUrl, {String quality = 'bestaudio'}) async {
    final fmt = quality == 'worstaudio'
        ? 'worstaudio/worstaudio*/worst'
        : 'bestaudio/bestaudio*/best';
    final cacheKey = 'audio:$watchUrl:$fmt';
    final cached = _getCached(cacheKey);
    if (cached != null) return cached;

    final binary = await _resolver.resolve();
    final result = await Process.run(
      binary.path,
      [
        ..._buildAuthArgs(),
        '-f',
        fmt,
        '--get-url',
        '--no-warnings',
        '--no-playlist',
        '--no-check-certificates',
        watchUrl,
      ],
      runInShell: Platform.isWindows,
    ).timeout(const Duration(seconds: 30));

    if (result.exitCode != 0) {
      final stderr = (result.stderr as String).trim();
      throw YtdlpException(stderr.isNotEmpty ? stderr : 'yt-dlp failed');
    }

    final url = (result.stdout as String)
        .trim()
        .split('\n')
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
    if (url.isEmpty) {
      throw YtdlpException('yt-dlp returned no URL');
    }

    _setCached(cacheKey, url);
    return url;
  }

  Future<String> downloadAudio({
    required String watchUrl,
    required String outputPath,
  }) async {
    final binary = await _resolver.resolve();
    final outputTemplate = outputPath.endsWith('.mp3')
        ? outputPath
        : '$outputPath.%(ext)s';

    final completer = Completer<String>();
    _activeDownload = await Process.start(
      binary.path,
      [
        ..._buildAuthArgs(),
        '-f',
        'bestaudio/bestaudio*/best',
        '-x',
        '--audio-format',
        'mp3',
        '--audio-quality',
        '0',
        '--no-part',
        '--no-warnings',
        '--no-playlist',
        '--no-check-certificates',
        '-o',
        outputTemplate,
        watchUrl,
      ],
      runInShell: Platform.isWindows,
    );

    final stderr = <int>[];
    _activeDownload!.stderr.listen(stderr.addAll);
    unawaited(_activeDownload!.exitCode.then((code) {
      _activeDownload = null;
      if (completer.isCompleted) return;
      if (code != 0) {
        final message = String.fromCharCodes(stderr).trim();
        completer.completeError(
          YtdlpException(message.isNotEmpty ? message : 'Download failed ($code)'),
        );
        return;
      }

      final expected = outputPath.endsWith('.mp3')
          ? outputPath
          : _findDownloadedFile(outputPath);
      if (expected == null || !File(expected).existsSync()) {
        completer.completeError(YtdlpException('Download completed but file missing'));
        return;
      }
      completer.complete(expected);
    }));

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        cancelDownload();
        throw YtdlpException('Download timed out');
      },
    );
  }

  void cancelDownload() {
    _activeDownload?.kill();
    _activeDownload = null;
  }

  void invalidateStreamCache([String? watchUrl]) {
    if (watchUrl == null) {
      _streamCache.clear();
      return;
    }
    _streamCache.removeWhere((key, _) => key.contains(watchUrl));
  }

  String? _findDownloadedFile(String outputPath) {
    final dir = File(outputPath).parent;
    if (!dir.existsSync()) return null;
    final base = outputPath.split(Platform.pathSeparator).last;
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.contains(base)) {
        return entity.path;
      }
    }
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        return entity.path;
      }
    }
    return null;
  }

  String? _getCached(String key) {
    final entry = _streamCache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _streamCache.remove(key);
      return null;
    }
    return entry.value;
  }

  void _setCached(String key, String value) {
    _streamCache[key] = _CacheEntry(
      value,
      DateTime.now().add(_cacheTtl),
    );
    if (_streamCache.length > 200) {
      final now = DateTime.now();
      _streamCache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
    }
  }

  List<String> _buildAuthArgs() {
    final auth = _authSettings();
    switch (auth.source) {
      case YtdlpCookieSource.none:
        return const [];
      case YtdlpCookieSource.file:
        final path = auth.cookiesFilePath;
        if (path == null || path.isEmpty || !File(path).existsSync()) {
          return const [];
        }
        return ['--cookies', path];
      case YtdlpCookieSource.browser:
        final browser = auth.browser.trim();
        if (browser.isEmpty) return const [];
        return ['--cookies-from-browser', browser];
    }
  }
}
