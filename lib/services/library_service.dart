import 'package:path/path.dart' as p;

import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/metadata_override_repository.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/library_search_results.dart';
import 'package:music_player/ui/models/track.dart';

class LibraryService {
  LibraryService(
    this._libraryRepository,
    this._settingsService,
    this._overrideRepository,
  );

  final LibraryRepository _libraryRepository;
  final SettingsService _settingsService;
  final MetadataOverrideRepository _overrideRepository;

  Map<String, TrackMetadataOverride>? _overrideCache;
  String? _overrideCacheRoot;

  void ensureOpen() {
    final path = _settingsService.musicLibraryPath;
    if (path == null) return;
    if (_libraryRepository.isOpen && _libraryRepository.musicRoot == path) {
      _ensureOverridesLoaded(path);
      return;
    }
    _libraryRepository.open(path);
    _invalidateOverrideCache();
    _ensureOverridesLoaded(path);
  }

  void _ensureOverridesLoaded(String musicRoot) {
    if (_settingsService.metadataEditMode != MetadataEditMode.override) return;
    if (_overrideCache != null && _overrideCacheRoot == musicRoot) return;
    _overrideCache =
        _overrideRepository.loadTrackOverridesSync(musicRoot);
    _overrideCacheRoot = musicRoot;
  }

  void _invalidateOverrideCache() {
    _overrideCache = null;
    _overrideCacheRoot = null;
  }

  bool get isReady {
    if (!_settingsService.isLibraryConfigured) return false;
    ensureOpen();
    return _libraryRepository.isOpen;
  }

  List<Artist> getArtists() {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    return _libraryRepository.getArtists().map(_mapArtist).toList();
  }

  List<Album> getAlbums() {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    final artists = {
      for (final artist in _libraryRepository.getArtists()) artist.id: artist.name,
    };
    return _libraryRepository
        .getAlbums()
        .map((album) => _mapAlbum(album, artists[album.artistId] ?? ''))
        .toList();
  }

  Artist? getArtistById(String id) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return null;
    final record = _libraryRepository.getArtistById(id);
    return record == null ? null : _mapArtist(record);
  }

  Album? getAlbumById(String id) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return null;
    final record = _libraryRepository.getAlbumById(id);
    if (record == null) return null;
    final artist = _libraryRepository.getArtistById(record.artistId);
    return _mapAlbum(record, artist?.name ?? '');
  }

  List<Track> getTracksForAlbum(String albumId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    return _mapTracks(_libraryRepository.getTracksForAlbum(albumId));
  }

  List<Track> getTracksForArtist(String artistId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    return _mapTracks(_libraryRepository.getTracksForArtist(artistId));
  }

  List<Track> getAllTracks() {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    return _mapTracks(_libraryRepository.getAllTracks());
  }

  Track? getTrackById(String id) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return null;
    final record = _libraryRepository.getTrackById(id);
    if (record == null) return null;
    final mapped = _mapTracks([record]);
    return mapped.isEmpty ? null : mapped.first;
  }

  List<Album> getAlbumsForArtist(String artistId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    final artist = _libraryRepository.getArtistById(artistId);
    final artistName = artist?.name ?? '';
    return _libraryRepository
        .getAlbumsForArtist(artistId)
        .map((album) => _mapAlbum(album, artistName))
        .toList();
  }

  List<Album> getOtherAlbumsByArtist(
    String artistId, {
    required String excludeAlbumId,
  }) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    final artist = _libraryRepository.getArtistById(artistId);
    final artistName = artist?.name ?? '';
    return _libraryRepository
        .getOtherAlbumsByArtist(artistId, excludeAlbumId: excludeAlbumId)
        .map((album) => _mapAlbum(album, artistName))
        .toList();
  }

  LibrarySearchResults search(String query, {int limitPerCategory = 20}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return LibrarySearchResults.empty;

    ensureOpen();
    if (!_libraryRepository.isOpen) return LibrarySearchResults.empty;

    final artistRecords =
        _libraryRepository.searchArtists(trimmed, limit: limitPerCategory);
    final albumRecords =
        _libraryRepository.searchAlbums(trimmed, limit: limitPerCategory);
    final trackRecords =
        _libraryRepository.searchTracks(trimmed, limit: limitPerCategory);

    final artists = artistRecords.map(_mapArtist).toList();

    final artistNames = {
      for (final artist in _libraryRepository.getArtists()) artist.id: artist.name,
    };
    final albums = albumRecords
        .map((album) => _mapAlbum(album, artistNames[album.artistId] ?? ''))
        .toList();

    final tracks = _mapTracks(trackRecords);

    return LibrarySearchResults(
      artists: artists,
      albums: albums,
      tracks: tracks,
    );
  }

  HomeSections getHomeSections() {
    final albums = getAlbums();
    final artists = getArtists();

    return HomeSections(
      recentlyPlayed: const [],
      recentlyAdded: albums,
      favoriteAlbums: albums,
      favoriteArtists: artists,
    );
  }

  List<Track> _mapTracks(List<TrackRecord> records) {
    if (records.isEmpty) return [];

    final artistNames = <String, String>{};
    final albumTitles = <String, String?>{};
    final albumYears = <String, int?>{};
    final albumCovers = <String, String?>{};

    for (final record in records) {
      if (!artistNames.containsKey(record.artistId)) {
        artistNames[record.artistId] =
            _libraryRepository.getArtistById(record.artistId)?.name ?? '';
      }
      if (!albumTitles.containsKey(record.albumId)) {
        final album = _libraryRepository.getAlbumById(record.albumId);
        albumTitles[record.albumId] = album?.title;
        albumYears[record.albumId] = album?.year;
        albumCovers[record.albumId] = album?.coverPath;
      }
    }

    return records
        .map(
          (record) => _mapTrack(
            record,
            artistNames[record.artistId] ?? '',
            albumTitles[record.albumId],
            albumYears[record.albumId],
            albumCovers[record.albumId],
          ),
        )
        .toList();
  }

  Track _mapTrack(
    TrackRecord record,
    String artistName,
    String? albumTitle,
    int? albumYear,
    String? albumCoverPath,
  ) {
    var title = record.title;
    var artist = artistName;
    var album = albumTitle;
    var year = albumYear;
    var coverPath = record.coverPath ?? albumCoverPath;
    var featuredArtists = record.featuredArtists;
    var albumArtist = record.albumArtist;
    var trackNumber = record.trackNumber;
    var genre = record.genre;
    var discNumber = record.discNumber;

    if (_settingsService.metadataEditMode == MetadataEditMode.override) {
      final override = _overrideCache?[record.id];
      if (override != null) {
        title = override.title ?? title;
        artist = override.artist ?? artist;
        album = override.album ?? album;
        year = override.year ?? year;
        featuredArtists = override.featuredArtists ?? featuredArtists;
        albumArtist = override.albumArtist ?? albumArtist;
        trackNumber = override.trackNumber ?? trackNumber;
        genre = override.genre ?? genre;
        discNumber = override.discNumber ?? discNumber;
        if (override.coverPath != null) {
          final musicRoot = _settingsService.musicLibraryPath;
          if (musicRoot != null) {
            coverPath = p.isAbsolute(override.coverPath!)
                ? override.coverPath
                : p.join(musicRoot, override.coverPath!);
          }
        }
      }
    }

    return Track(
      id: record.id,
      filePath: record.filePath,
      title: title,
      artist: artist,
      artistId: record.artistId,
      albumId: record.albumId,
      album: album,
      year: year,
      albumArtUrl: coverPath,
      duration: Duration(milliseconds: record.durationMs),
      trackNumber: trackNumber,
      genre: genre,
      format: record.format,
      bitrate: record.bitrate,
      featuredArtists: featuredArtists,
      albumArtist: albumArtist,
      discNumber: discNumber,
    );
  }

  Future<void> preloadOverrides() async {
    refreshOverrides();
    final path = _settingsService.musicLibraryPath;
    if (path != null) {
      _ensureOverridesLoaded(path);
    }
  }

  void refreshOverrides() {
    _invalidateOverrideCache();
  }

  Album _mapAlbum(AlbumRecord record, String artistName) {
    return Album(
      id: record.id,
      title: record.title,
      artist: artistName,
      artistId: record.artistId,
      coverUrl: record.coverPath,
      year: record.year,
    );
  }

  Artist _mapArtist(ArtistRecord record) {
    return Artist(
      id: record.id,
      name: record.name,
      imageUrl: record.coverPath,
    );
  }
}
