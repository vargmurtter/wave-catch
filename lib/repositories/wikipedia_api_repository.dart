import 'dart:convert';

import 'package:http/http.dart' as http;

class RemoteArtistInfo {
  const RemoteArtistInfo({
    this.description,
    this.imageUrl,
  });

  final String? description;
  final String? imageUrl;

  bool get hasContent =>
      (description != null && description!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);
}

class WikipediaApiRepository {
  Future<RemoteArtistInfo?> fetchArtistInfo({
    required List<String> wikipediaUrls,
    String? wikidataId,
  }) async {
    final ruTitle = _findWikipediaTitle(wikipediaUrls, 'ru');
    final enTitle = _findWikipediaTitle(wikipediaUrls, 'en');

    String? description;
    String? imageUrl;

    if (ruTitle != null) {
      final summary = await _fetchSummary('ru', ruTitle);
      description = summary?.description;
      imageUrl = summary?.imageUrl;
    }

    if ((description == null || description.isEmpty) && enTitle != null) {
      final summary = await _fetchSummary('en', enTitle);
      description ??= summary?.description;
      imageUrl ??= summary?.imageUrl;
    }

    if (wikidataId != null) {
      final wikidata = await _fetchWikidata(wikidataId);

      if ((description == null || description.isEmpty) &&
          wikidata.description != null) {
        description = wikidata.description;
      }

      if ((ruTitle == null && enTitle == null) &&
          wikidata.ruTitle != null &&
          (description == null || description.isEmpty)) {
        final summary = await _fetchSummary('ru', wikidata.ruTitle!);
        description ??= summary?.description;
        imageUrl ??= summary?.imageUrl;
      }

      if ((description == null || description.isEmpty) &&
          wikidata.enTitle != null) {
        final summary = await _fetchSummary('en', wikidata.enTitle!);
        description ??= summary?.description;
        imageUrl ??= summary?.imageUrl;
      }

      imageUrl ??= wikidata.imageUrl;
    }

    if (description == null && imageUrl == null) return null;

    final trimmedDescription = description?.trim();
    return RemoteArtistInfo(
      description: trimmedDescription == null || trimmedDescription.isEmpty
          ? null
          : trimmedDescription,
      imageUrl: imageUrl,
    );
  }

  String? _findWikipediaTitle(List<String> urls, String lang) {
    final host = '$lang.wikipedia.org';
    for (final url in urls) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host != host) continue;

      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty || segments.first != 'wiki') continue;
      if (segments.length < 2) continue;

      return Uri.decodeComponent(segments.sublist(1).join('/'));
    }
    return null;
  }

  Future<({String? description, String? imageUrl})?> _fetchSummary(
    String lang,
    String title,
  ) async {
    final encodedTitle = Uri.encodeComponent(title.replaceAll(' ', '_'));
    final uri = Uri.parse(
      'https://$lang.wikipedia.org/api/rest_v1/page/summary/$encodedTitle',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final extract = decoded['extract'];
      final thumbnail = decoded['thumbnail'];
      String? imageUrl;
      if (thumbnail is Map<String, dynamic>) {
        final source = thumbnail['source'];
        if (source is String && source.isNotEmpty) {
          imageUrl = source;
        }
      }

      return (
        description: extract is String ? extract.trim() : null,
        imageUrl: imageUrl,
      );
    } catch (_) {
      return null;
    }
  }

  Future<
      ({
        String? description,
        String? imageUrl,
        String? ruTitle,
        String? enTitle,
      })> _fetchWikidata(String wikidataId) async {
    final uri = Uri.parse(
      'https://www.wikidata.org/wiki/Special:EntityData/$wikidataId.json',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        return (
          description: null,
          imageUrl: null,
          ruTitle: null,
          enTitle: null,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return (
          description: null,
          imageUrl: null,
          ruTitle: null,
          enTitle: null,
        );
      }

      final entities = decoded['entities'];
      if (entities is! Map<String, dynamic>) {
        return (
          description: null,
          imageUrl: null,
          ruTitle: null,
          enTitle: null,
        );
      }

      final entity = entities[wikidataId];
      if (entity is! Map<String, dynamic>) {
        return (
          description: null,
          imageUrl: null,
          ruTitle: null,
          enTitle: null,
        );
      }

      String? description;
      final descriptions = entity['descriptions'];
      if (descriptions is Map<String, dynamic>) {
        final ru = descriptions['ru'];
        if (ru is Map<String, dynamic>) {
          final value = ru['value'];
          if (value is String && value.isNotEmpty) {
            description = value;
          }
        }
        if (description == null) {
          final en = descriptions['en'];
          if (en is Map<String, dynamic>) {
            final value = en['value'];
            if (value is String && value.isNotEmpty) {
              description = value;
            }
          }
        }
      }

      String? ruTitle;
      String? enTitle;
      final sitelinks = entity['sitelinks'];
      if (sitelinks is Map<String, dynamic>) {
        final ruwiki = sitelinks['ruwiki'];
        if (ruwiki is Map<String, dynamic>) {
          final title = ruwiki['title'];
          if (title is String) ruTitle = title;
        }
        final enwiki = sitelinks['enwiki'];
        if (enwiki is Map<String, dynamic>) {
          final title = enwiki['title'];
          if (title is String) enTitle = title;
        }
      }

      String? imageUrl;
      final claims = entity['claims'];
      if (claims is Map<String, dynamic>) {
        final p18 = claims['P18'];
        if (p18 is List) {
          for (final claim in p18) {
            if (claim is! Map<String, dynamic>) continue;
            final mainsnak = claim['mainsnak'];
            if (mainsnak is! Map<String, dynamic>) continue;
            final datavalue = mainsnak['datavalue'];
            if (datavalue is! Map<String, dynamic>) continue;
            final value = datavalue['value'];
            if (value is String && value.isNotEmpty) {
              imageUrl =
                  'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(value)}';
              break;
            }
          }
        }
      }

      return (
        description: description,
        imageUrl: imageUrl,
        ruTitle: ruTitle,
        enTitle: enTitle,
      );
    } catch (_) {
      return (
        description: null,
        imageUrl: null,
        ruTitle: null,
        enTitle: null,
      );
    }
  }
}
