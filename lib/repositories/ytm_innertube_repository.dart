import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:music_player/ui/models/explore_track.dart';

class ExploreSearchSuggestions {
  const ExploreSearchSuggestions({
    this.textSuggestions = const [],
    this.tracks = const [],
  });

  final List<String> textSuggestions;
  final List<ExploreTrack> tracks;
}

class YtmInnerTubeRepository {
  YtmInnerTubeRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String? _apiKey;
  Map<String, dynamic>? _context;
  bool _initDone = false;
  Future<void>? _initFuture;

  Future<void> _ensureSession() async {
    if (_initDone) return;
    _initFuture ??= _initSession();
    await _initFuture;
  }

  Future<void> _initSession() async {
    try {
      final response = await _client.get(
        Uri.parse('https://music.youtube.com/'),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml',
        },
      );
      final html = response.body;
      final visitorMatch =
          RegExp(r'"VISITOR_DATA"\s*:\s*"([^"]+)"').firstMatch(html);
      if (visitorMatch != null && _context != null) {
        final client = _context!['client'];
        if (client is Map<String, dynamic>) {
          client['visitorData'] = visitorMatch.group(1);
        }
      }

      final keyMatch =
          RegExp(r'"INNERTUBE_API_KEY"\s*:\s*"([^"]+)"').firstMatch(html);
      if (keyMatch != null) _apiKey = keyMatch.group(1);

      final ctxMatch = RegExp(
        r'"INNERTUBE_CONTEXT"\s*:\s*(\{[\s\S]*?\})\s*,\s*"INNERTUBE_CONTEXT_CLIENT_NAME"',
      ).firstMatch(html);
      if (ctxMatch != null) {
        _context = jsonDecode(ctxMatch.group(1)! ) as Map<String, dynamic>;
      }
    } on Object {
      // Fall through to defaults.
    }

    _apiKey ??= 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WE5qSJx3OM';
    _context ??= {
      'client': {
        'clientName': 'WEB_REMIX',
        'clientVersion': '1.20241231.01.00',
        'hl': 'en',
        'gl': 'US',
        'platform': 'DESKTOP',
      },
    };
    _initDone = true;
  }

  Future<Map<String, dynamic>> _musicRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    await _ensureSession();
    final uri = Uri.parse(
      'https://music.youtube.com/youtubei/v1/$endpoint'
      '?key=$_apiKey&prettyPrint=false',
    );
    final payload = {
      'context': _context,
      ...body,
    };
    final response = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'https://music.youtube.com',
        'Referer': 'https://music.youtube.com/',
        'X-Origin': 'https://music.youtube.com',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw StateError('YTM request failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<ExploreTrack>> searchSongs(String query) async {
    try {
      final raw = await _musicRequest('search', {
        'query': query,
        'params': 'EgWKAQIIAWoOEAMQBBAJEAoQBRAREBU%3D',
      });
      return _parseSongShelves(raw);
    } on Object {
      return [];
    }
  }

  Future<ExploreSearchSuggestions> searchSuggestions(String query) async {
    try {
      final raw = await _musicRequest('music/get_search_suggestions', {
        'input': query,
      });
      final sections = raw['contents'] as List<dynamic>? ?? [];
      final textSuggestions = <String>[];
      final tracks = <ExploreTrack>[];

      for (final section in sections) {
        if (section is! Map<String, dynamic>) continue;
        final renderer = section['searchSuggestionsSectionRenderer'];
        if (renderer is! Map<String, dynamic>) continue;
        final items = renderer['contents'] as List<dynamic>? ?? [];
        for (final item in items) {
          if (item is! Map<String, dynamic>) continue;
          final suggestion = item['searchSuggestionRenderer'];
          if (suggestion is Map<String, dynamic>) {
            final runs = suggestion['suggestion']?['runs'] as List<dynamic>? ?? [];
            final text = runs
                .whereType<Map<String, dynamic>>()
                .map((r) => r['text'] as String? ?? '')
                .join();
            if (text.isNotEmpty) textSuggestions.add(text);
            continue;
          }

          final row = item['musicResponsiveListItemRenderer'];
          if (row is! Map<String, dynamic>) continue;
          final nav = row['navigationEndpoint'] as Map<String, dynamic>?;
          final watchId = nav?['watchEndpoint']?['videoId'] as String?;
          if (watchId == null) continue;
          final mapped = _mapSongFromShelf(row);
          if (mapped != null) tracks.add(mapped);
        }
      }

      return ExploreSearchSuggestions(
        textSuggestions: textSuggestions,
        tracks: tracks,
      );
    } on Object {
      return const ExploreSearchSuggestions();
    }
  }

  Future<List<ExploreTrack>> getUpNexts(String videoId) async {
    try {
      final raw = await _musicRequest('next', {
        'videoId': videoId,
        'playlistId': 'RDAMVM$videoId',
        'isAudioOnly': true,
      });
      final contents = _deepGet<List<dynamic>>(raw, [
        'contents',
        'singleColumnMusicWatchNextResultsRenderer',
        'tabbedRenderer',
        'watchNextTabbedResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'musicQueueRenderer',
        'content',
        'playlistPanelRenderer',
        'contents',
      ]) ?? [];

      return contents.skip(1).map((item) {
        if (item is! Map<String, dynamic>) return null;
        final r = item['playlistPanelVideoRenderer'];
        if (r is! Map<String, dynamic>) return null;
        final vid = r['navigationEndpoint']?['watchEndpoint']?['videoId']
            as String?;
        if (vid == null) return null;

        final allRuns =
            r['longBylineText']?['runs'] as List<dynamic>? ?? [];
        final dotIdx = allRuns.indexWhere(
          (run) => run is Map && run['text'] == ' • ',
        );
        final artistRuns = dotIdx >= 0
            ? allRuns.sublist(0, dotIdx)
            : allRuns;
        final artists = _parseArtistsFromRuns(artistRuns);
        final durationText =
            r['lengthText']?['runs']?[0]?['text'] as String? ?? '';
        final thumbs = r['thumbnail']?['thumbnails'] as List<dynamic>? ?? [];

        return ExploreTrack(
          videoId: vid,
          title: r['title']?['runs']?[0]?['text'] as String? ?? 'Unknown',
          artist: artists.isNotEmpty
              ? artists.map((a) => a.name).join(', ')
              : 'Unknown Artist',
          artistId: artists.isNotEmpty ? artists.first.id : null,
          artists: artists,
          thumbnailUrl: _getSquareThumbnail(thumbs),
          duration: _parseDurationText(durationText),
        );
      }).whereType<ExploreTrack>().toList();
    } on Object {
      return [];
    }
  }

  Future<List<ExploreTrack>> getArtistTopSongs(String artistId) async {
    try {
      final raw = await _musicRequest('browse', {'browseId': artistId});
      final sections = _deepGet<List<dynamic>>(raw, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
      ]) ?? [];

      for (final section in sections) {
        if (section is! Map<String, dynamic>) continue;
        final shelf = section['musicShelfRenderer'];
        if (shelf is! Map<String, dynamic>) continue;
        final items = shelf['contents'] as List<dynamic>? ?? [];
        final tracks = <ExploreTrack>[];
        for (final item in items) {
          if (item is! Map<String, dynamic>) continue;
          final row = item['musicResponsiveListItemRenderer'];
          if (row is! Map<String, dynamic>) continue;
          final mapped = _mapSongFromShelf(row);
          if (mapped != null) tracks.add(mapped);
        }
        if (tracks.isNotEmpty) return tracks;
      }
      return [];
    } on Object {
      return [];
    }
  }

  List<ExploreTrack> _parseSongShelves(Map<String, dynamic> raw) {
    final shelves = _deepGet<List<dynamic>>(raw, [
      'contents',
      'tabbedSearchResultsRenderer',
      'tabs',
      0,
      'tabRenderer',
      'content',
      'sectionListRenderer',
      'contents',
    ]) ?? [];

    final tracks = <ExploreTrack>[];
    for (final shelf in shelves) {
      if (shelf is! Map<String, dynamic>) continue;
      final contents =
          shelf['musicShelfRenderer']?['contents'] as List<dynamic>? ?? [];
      for (final entry in contents) {
        if (entry is! Map<String, dynamic>) continue;
        final row = entry['musicResponsiveListItemRenderer'];
        if (row is! Map<String, dynamic>) continue;
        final mapped = _mapSongFromShelf(row);
        if (mapped != null) tracks.add(mapped);
      }
    }
    return tracks;
  }

  ExploreTrack? _mapSongFromShelf(Map<String, dynamic> row) {
    final cols = row['flexColumns'] as List<dynamic>? ?? [];
    if (cols.isEmpty) return null;

    final col0 = cols[0] as Map<String, dynamic>?;
    final runs0 = col0?['musicResponsiveListItemFlexColumnRenderer']?['text']
        ?['runs'] as List<dynamic>? ?? [];
    if (runs0.isEmpty) return null;

    final firstRun = runs0.first as Map<String, dynamic>?;
    final videoId =
        firstRun?['navigationEndpoint']?['watchEndpoint']?['videoId']
            as String?;
    if (videoId == null) return null;

    final title = runs0
        .whereType<Map<String, dynamic>>()
        .map((r) => r['text'] as String? ?? '')
        .join();

    final col1 = cols.length > 1 ? cols[1] as Map<String, dynamic>? : null;
    final subtitleRuns = col1?['musicResponsiveListItemFlexColumnRenderer']
            ?['text']?['runs'] as List<dynamic>? ??
        [];
    final dotIdx = subtitleRuns.indexWhere(
      (run) => run is Map && run['text'] == ' • ',
    );
    final artistRuns =
        dotIdx >= 0 ? subtitleRuns.sublist(0, dotIdx) : subtitleRuns;
    final artists = _parseArtistsFromRuns(artistRuns);

    String? album;
    String? albumId;
    for (var i = 2; i < cols.length; i++) {
      final runs = (cols[i] as Map<String, dynamic>?)?[
              'musicResponsiveListItemFlexColumnRenderer']?['text']?['runs']
          as List<dynamic>? ??
          [];
      for (final run in runs) {
        if (run is! Map<String, dynamic>) continue;
        final pageType = run['navigationEndpoint']?['browseEndpoint']
                ?['browseEndpointContextSupportedConfigs']
            ?['browseEndpointContextMusicConfig']?['pageType'] as String?;
        if (pageType == 'MUSIC_PAGE_TYPE_ALBUM') {
          album = run['text'] as String?;
          albumId = run['navigationEndpoint']?['browseEndpoint']?['browseId']
              as String?;
          break;
        }
      }
      if (album != null) break;
    }

    final durationText = row['fixedColumns']?[0]
            ?['musicResponsiveListItemFixedColumnRenderer']?['text']?['runs']
        ?[0]?['text'] as String? ??
        '';
    final thumbs = row['thumbnail']?['musicThumbnailRenderer']?['thumbnail']
            ?['thumbnails'] as List<dynamic>? ??
        [];

    return ExploreTrack(
      videoId: videoId,
      title: title.isNotEmpty ? title : 'Unknown',
      artist: artists.isNotEmpty
          ? artists.map((a) => a.name).join(', ')
          : 'Unknown Artist',
      artistId: artists.isNotEmpty ? artists.first.id : null,
      artists: artists,
      album: album,
      albumId: albumId,
      thumbnailUrl: _getSquareThumbnail(thumbs),
      duration: _parseDurationText(durationText),
    );
  }

  List<ExploreArtist> _parseArtistsFromRuns(List<dynamic> runs) {
    final artistRuns = <Map<String, dynamic>>[];
    for (final run in runs) {
      if (run is! Map<String, dynamic>) continue;
      final pageType = run['navigationEndpoint']?['browseEndpoint']
              ?['browseEndpointContextSupportedConfigs']
          ?['browseEndpointContextMusicConfig']?['pageType'] as String?;
      if (pageType == 'MUSIC_PAGE_TYPE_ARTIST') {
        artistRuns.add(run);
      }
    }

    if (artistRuns.isNotEmpty) {
      return artistRuns
          .map(
            (run) => ExploreArtist(
              name: run['text'] as String? ?? '',
              id: run['navigationEndpoint']?['browseEndpoint']?['browseId']
                  as String?,
            ),
          )
          .where((a) => a.name.isNotEmpty)
          .toList();
    }

    if (runs.isNotEmpty) {
      final text = runs
          .whereType<Map<String, dynamic>>()
          .map((r) => r['text'] as String? ?? '')
          .join();
      final dotIdx = text.indexOf(' • ');
      final artistText = dotIdx >= 0 ? text.substring(0, dotIdx) : text;
      return artistText
          .split(RegExp(r',\s*|\s*&\s*'))
          .map((name) => ExploreArtist(name: name.trim()))
          .where((a) => a.name.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String _getSquareThumbnail(List<dynamic> thumbnails, {int size = 226}) {
    final url = _getBestThumbnail(thumbnails);
    if (url.isEmpty) return '';
    if (url.contains('lh3.googleusercontent.com')) {
      return url.replaceAll(
        RegExp(r'=(?:w\d+-h\d+|s\d+|p-w\d+).*$'),
        '=w$size-h$size-l90-rj',
      );
    }
    return url;
  }

  String _getBestThumbnail(List<dynamic> thumbnails) {
    if (thumbnails.isEmpty) return '';
    final sorted = thumbnails
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort(
        (a, b) =>
            ((b['width'] as int?) ?? 0).compareTo((a['width'] as int?) ?? 0),
      );
    return sorted.first['url'] as String? ?? '';
  }

  Duration _parseDurationText(String text) {
    if (text.isEmpty) return Duration.zero;
    final parts = text.split(':').map(int.tryParse).toList();
    if (parts.length == 2 && parts.every((p) => p != null)) {
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    }
    if (parts.length == 3 && parts.every((p) => p != null)) {
      return Duration(
        hours: parts[0]!,
        minutes: parts[1]!,
        seconds: parts[2]!,
      );
    }
    return Duration.zero;
  }

  T? _deepGet<T>(Map<String, dynamic> map, List<dynamic> path) {
    dynamic current = map;
    for (final segment in path) {
      if (current is Map<String, dynamic>) {
        if (segment is String) {
          current = current[segment];
        } else {
          return null;
        }
      } else if (current is List<dynamic> && segment is int) {
        if (segment < 0 || segment >= current.length) return null;
        current = current[segment];
      } else {
        return null;
      }
    }
    return current is T ? current : null;
  }
}
