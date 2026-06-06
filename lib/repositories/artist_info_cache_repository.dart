import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:music_player/repositories/entities/artist_info_record.dart';

class ArtistInfoCacheRepository {
  static const _cacheFileName = 'lastfm_artist_cache.json';
  static const _imagesDirName = 'lastfm_images';

  Future<Directory> _appDir() async {
    final supportDir = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(supportDir.path, 'music_player'));
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return appDir;
  }

  Future<File> _cacheFile() async {
    final appDir = await _appDir();
    return File(p.join(appDir.path, _cacheFileName));
  }

  Future<Directory> _imagesDir() async {
    final appDir = await _appDir();
    final imagesDir = Directory(p.join(appDir.path, _imagesDirName));
    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }
    return imagesDir;
  }

  Future<Map<String, ArtistInfoRecord>> _readAll() async {
    final file = await _cacheFile();
    if (!file.existsSync()) return {};

    try {
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return {};

      final records = <String, ArtistInfoRecord>{};
      for (final entry in json.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;
        records[entry.key] = ArtistInfoRecord.fromJson(value);
      }
      return records;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeAll(Map<String, ArtistInfoRecord> records) async {
    final file = await _cacheFile();
    final json = {
      for (final entry in records.entries) entry.key: entry.value.toJson(),
    };
    await file.writeAsString(jsonEncode(json));
  }

  Future<ArtistInfoRecord?> get(String artistId) async {
    final records = await _readAll();
    final record = records[artistId];
    if (record == null || !record.hasContent) return null;

    if (record.imagePath != null) {
      final file = File(record.imagePath!);
      if (!file.existsSync()) {
        return ArtistInfoRecord(
          artistId: record.artistId,
          description: record.description,
          cachedAt: record.cachedAt,
        );
      }
    }

    return record;
  }

  Future<String?> downloadImage({
    required String artistId,
    required String imageUrl,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }

      final imagesDir = await _imagesDir();
      final extension = _extensionForContentType(
        response.headers['content-type'],
        imageUrl,
      );
      final file = File(p.join(imagesDir.path, '$artistId.$extension'));
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  String _extensionForContentType(String? contentType, String url) {
    final type = contentType?.toLowerCase() ?? '';
    if (type.contains('png')) return 'png';
    if (type.contains('webp')) return 'webp';
    if (type.contains('gif')) return 'gif';

    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.png')) return 'png';
    if (lowerUrl.endsWith('.webp')) return 'webp';
    if (lowerUrl.endsWith('.gif')) return 'gif';

    return 'jpg';
  }

  Future<void> save(ArtistInfoRecord record) async {
    if (!record.hasContent) return;

    final records = await _readAll();
    records[record.artistId] = record;
    await _writeAll(records);
  }
}
