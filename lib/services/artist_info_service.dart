import 'package:music_player/repositories/artist_info_cache_repository.dart';
import 'package:music_player/repositories/entities/artist_info_record.dart';
import 'package:music_player/repositories/musicbrainz_api_repository.dart';
import 'package:music_player/repositories/wikipedia_api_repository.dart';
import 'package:music_player/ui/models/artist_info.dart';

class ArtistInfoService {
  ArtistInfoService(
    this._musicBrainzApiRepository,
    this._wikipediaApiRepository,
    this._cacheRepository,
  );

  final MusicBrainzApiRepository _musicBrainzApiRepository;
  final WikipediaApiRepository _wikipediaApiRepository;
  final ArtistInfoCacheRepository _cacheRepository;

  final Map<String, ArtistInfo> _memoryCache = {};
  var _diskCacheLoaded = false;

  Future<void> ensureCacheLoaded() async {
    if (_diskCacheLoaded) return;

    final records = await _cacheRepository.loadAll();
    for (final record in records.values) {
      if (!record.hasContent) continue;
      _memoryCache.putIfAbsent(record.artistId, () => _mapRecord(record));
    }
    _diskCacheLoaded = true;
  }

  String? cachedImagePath(String artistId) {
    return _memoryCache[artistId]?.imagePath;
  }

  Future<ArtistInfo?> loadArtistInfo({
    required String artistId,
    required String artistName,
  }) async {
    final cached = _memoryCache[artistId];
    if (cached != null) return cached.hasContent ? cached : null;

    final diskRecord = await _cacheRepository.get(artistId);
    if (diskRecord != null && diskRecord.hasContent) {
      final info = _mapRecord(diskRecord);
      _memoryCache[artistId] = info;
      return info;
    }

    RemoteArtistInfo? remote;
    try {
      remote = await _fetchRemoteArtistInfo(artistName);
    } catch (_) {
      return null;
    }

    if (remote == null || !remote.hasContent) return null;

    String? imagePath;
    if (remote.imageUrl != null) {
      imagePath = await _cacheRepository.downloadImage(
        artistId: artistId,
        imageUrl: remote.imageUrl!,
      );
    }

    if (remote.description == null && imagePath == null) return null;

    final record = ArtistInfoRecord(
      artistId: artistId,
      description: remote.description,
      imagePath: imagePath,
      cachedAt: DateTime.now(),
    );

    await _cacheRepository.save(record);

    final info = _mapRecord(record);
    _memoryCache[artistId] = info;
    return info;
  }

  Future<RemoteArtistInfo?> _fetchRemoteArtistInfo(String artistName) async {
    final mbid = await _musicBrainzApiRepository.findArtistMbid(artistName);
    if (mbid == null) return null;

    final externalUrls =
        await _musicBrainzApiRepository.getArtistExternalUrls(mbid);
    if (externalUrls == null || !externalUrls.hasLinks) return null;

    return _wikipediaApiRepository.fetchArtistInfo(
      wikipediaUrls: externalUrls.wikipediaUrls,
      wikidataId: externalUrls.wikidataId,
    );
  }

  ArtistInfo _mapRecord(ArtistInfoRecord record) {
    return ArtistInfo(
      description: record.description,
      imagePath: record.imagePath,
    );
  }
}
