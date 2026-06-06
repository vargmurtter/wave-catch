import 'dart:convert';

import 'package:http/http.dart' as http;

class LastFmArtistData {
  const LastFmArtistData({
    this.description,
    this.imageUrl,
  });

  final String? description;
  final String? imageUrl;

  bool get hasContent =>
      (description != null && description!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);
}

class LastFmApiRepository {
  static const _baseUrl = 'https://ws.audioscrobbler.com/2.0/';

  static const _imageSizePriority = [
    'mega',
    'extralarge',
    'large',
    'medium',
    'small',
  ];

  Future<LastFmArtistData?> fetchArtistInfo({
    required String artistName,
    required String apiKey,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'method': 'artist.getinfo',
        'artist': artistName,
        'api_key': apiKey,
        'format': 'json',
        'lang': 'ru',
        'autocorrect': '1',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;

    final error = decoded['error'];
    if (error != null) return null;

    final artist = decoded['artist'];
    if (artist is! Map<String, dynamic>) return null;

    final description = _parseDescription(artist['bio']);
    final imageUrl = _parseBestImageUrl(artist['image']);

    if (description == null && imageUrl == null) return null;

    return LastFmArtistData(
      description: description,
      imageUrl: imageUrl,
    );
  }

  String? _parseDescription(Object? bio) {
    if (bio is! Map<String, dynamic>) return null;

    final summary = bio['summary'];
    if (summary is! String || summary.trim().isEmpty) return null;

    return _stripHtml(summary);
  }

  String? _parseBestImageUrl(Object? images) {
    if (images is! List) return null;

    final bySize = <String, String>{};
    for (final item in images) {
      if (item is! Map<String, dynamic>) continue;

      final size = item['size'];
      final text = item['#text'];
      if (size is! String || text is! String) continue;
      if (text.trim().isEmpty || _isPlaceholderImageUrl(text)) continue;

      bySize[size] = text.trim();
    }

    for (final size in _imageSizePriority) {
      final url = bySize[size];
      if (url != null) return url;
    }

    return null;
  }

  bool _isPlaceholderImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/default_') ||
        lower.contains('default_album') ||
        lower.contains('default_artist') ||
        lower.endsWith('/default.png') ||
        lower.contains('2a96cbd8b46e442fc41c2b86b821562f');
  }

  String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();

    text = text.replaceFirst(
      RegExp(r'\s*Read more on Last\.fm\.?\s*$', caseSensitive: false),
      '',
    );
    text = text.replaceFirst(
      RegExp(
        r'\s*Подробнее на Last\.fm\.?\s*$',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceFirst(
      RegExp(
        r'\s*User-contributed text is available under the Creative Commons.*$',
        caseSensitive: false,
        dotAll: true,
      ),
      '',
    );

    return text.trim();
  }
}
