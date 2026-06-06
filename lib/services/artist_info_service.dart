import 'package:music_player/repositories/artist_info_cache_repository.dart';
import 'package:music_player/repositories/entities/artist_info_record.dart';
import 'package:music_player/repositories/lastfm_api_repository.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/artist_info.dart';

class ArtistInfoService {
  ArtistInfoService(
    this._lastFmApiRepository,
    this._cacheRepository,
    this._settingsService,
  );

  final LastFmApiRepository _lastFmApiRepository;
  final ArtistInfoCacheRepository _cacheRepository;
  final SettingsService _settingsService;

  final Map<String, ArtistInfo> _memoryCache = {};

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

    final apiKey = _settingsService.lastFmApiKey;
    if (apiKey == null || apiKey.isEmpty) return null;

    LastFmArtistData? remote;
    try {
      remote = await _lastFmApiRepository.fetchArtistInfo(
        artistName: artistName,
        apiKey: apiKey,
      );
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

  ArtistInfo _mapRecord(ArtistInfoRecord record) {
    return ArtistInfo(
      description: record.description,
      imagePath: record.imagePath,
    );
  }
}
