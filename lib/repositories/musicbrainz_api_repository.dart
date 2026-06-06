import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:music_player/app_info.dart';

class MusicBrainzExternalUrls {
  const MusicBrainzExternalUrls({
    this.wikipediaUrls = const [],
    this.wikidataId,
  });

  final List<String> wikipediaUrls;
  final String? wikidataId;

  bool get hasLinks => wikipediaUrls.isNotEmpty || wikidataId != null;
}

class MusicBrainzApiRepository {
  static const _baseUrl = 'https://musicbrainz.org/ws/2';
  static const _userAgent = '$kAppDisplayName/0.1.0 (desktop music player)';

  DateTime? _lastRequestAt;

  Future<String?> findArtistMbid(String name) async {
    final uri = Uri.parse('$_baseUrl/artist').replace(
      queryParameters: {
        'query': 'artist:"${name.replaceAll('"', '\\"')}"',
        'fmt': 'json',
        'limit': '5',
      },
    );

    final response = await _get(uri);
    if (response == null) return null;

    final decoded = jsonDecode(response);
    if (decoded is! Map<String, dynamic>) return null;

    final artists = decoded['artists'];
    if (artists is! List || artists.isEmpty) return null;

    final normalizedQuery = name.trim().toLowerCase();
    Map<String, dynamic>? bestMatch;
    var bestScore = -1;

    for (final item in artists) {
      if (item is! Map<String, dynamic>) continue;

      final artistName = item['name'];
      final id = item['id'];
      if (artistName is! String || id is! String) continue;

      if (artistName.trim().toLowerCase() == normalizedQuery) {
        return id;
      }

      final score = item['score'];
      final numericScore = score is int ? score : int.tryParse('$score') ?? 0;
      if (numericScore > bestScore) {
        bestScore = numericScore;
        bestMatch = item;
      }
    }

    return bestMatch?['id'] as String?;
  }

  Future<MusicBrainzExternalUrls?> getArtistExternalUrls(String mbid) async {
    final uri = Uri.parse('$_baseUrl/artist/$mbid').replace(
      queryParameters: {
        'inc': 'url-rels',
        'fmt': 'json',
      },
    );

    final response = await _get(uri);
    if (response == null) return null;

    final decoded = jsonDecode(response);
    if (decoded is! Map<String, dynamic>) return null;

    final relations = decoded['relations'];
    if (relations is! List) {
      return const MusicBrainzExternalUrls();
    }

    final wikipediaUrls = <String>[];
    String? wikidataId;

    for (final relation in relations) {
      if (relation is! Map<String, dynamic>) continue;

      final type = relation['type'];
      final url = relation['url'];
      if (type is! String || url is! Map<String, dynamic>) continue;

      final resource = url['resource'];
      if (resource is! String || resource.isEmpty) continue;

      if (type == 'wikidata') {
        wikidataId ??= _extractWikidataId(resource);
      } else if (type == 'wikipedia' || resource.contains('wikipedia.org')) {
        wikipediaUrls.add(resource);
      }
    }

    return MusicBrainzExternalUrls(
      wikipediaUrls: wikipediaUrls,
      wikidataId: wikidataId,
    );
  }

  String? _extractWikidataId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final id = segments.last;
    if (RegExp(r'^Q\d+$').hasMatch(id)) return id;
    return null;
  }

  Future<String?> _get(Uri uri) async {
    await _throttle();

    try {
      final response = await http
          .get(
            uri,
            headers: {'User-Agent': _userAgent},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;
      return response.body;
    } catch (_) {
      return null;
    }
  }

  Future<void> _throttle() async {
    final lastRequest = _lastRequestAt;
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest);
      if (elapsed.inMilliseconds < 1000) {
        await Future<void>.delayed(
          Duration(milliseconds: 1000 - elapsed.inMilliseconds),
        );
      }
    }
    _lastRequestAt = DateTime.now();
  }
}
