import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/services/settings_service.dart';
import 'package:music_player/ui/models/album.dart';
import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/models/home_sections.dart';
import 'package:music_player/ui/models/track.dart';

class LibraryService {
  LibraryService(this._libraryRepository, this._settingsService);

  final LibraryRepository _libraryRepository;
  final SettingsService _settingsService;

  void ensureOpen() {
    final path = _settingsService.musicLibraryPath;
    if (path == null) return;
    if (_libraryRepository.isOpen && _libraryRepository.musicRoot == path) {
      return;
    }
    _libraryRepository.open(path);
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
    return Track(
      id: record.id,
      filePath: record.filePath,
      title: record.title,
      artist: artistName,
      artistId: record.artistId,
      albumId: record.albumId,
      album: albumTitle,
      year: albumYear,
      albumArtUrl: record.coverPath ?? albumCoverPath,
      duration: Duration(milliseconds: record.durationMs),
      trackNumber: record.trackNumber,
      genre: record.genre,
      format: record.format,
      bitrate: record.bitrate,
    );
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
