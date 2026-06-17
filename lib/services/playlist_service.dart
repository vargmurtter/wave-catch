import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/playlist_repository.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/services/scanner/scan_rules.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/models/track.dart';

class PlaylistService {
  PlaylistService(this._libraryRepository, this._libraryService);

  final LibraryRepository _libraryRepository;
  final LibraryService _libraryService;

  PlaylistRepository get _playlistRepository =>
      _libraryRepository.playlistRepository;

  void ensureOpen() => _libraryService.ensureOpen();

  List<Playlist> getPlaylists() {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    return _playlistRepository.getPlaylists().map(_mapPlaylist).toList();
  }

  Playlist? getPlaylistById(String id) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return null;
    final record = _playlistRepository.getPlaylistById(id);
    if (record == null) return null;
    return _mapPlaylist(record);
  }

  List<Track> getTracksForPlaylist(String playlistId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return [];
    final trackIds = _playlistRepository.getTrackIdsForPlaylist(playlistId);
    final tracks = <Track>[];
    for (final id in trackIds) {
      final track = _libraryService.getTrackById(id);
      if (track != null) {
        tracks.add(track);
      }
    }
    return tracks;
  }

  Playlist createPlaylist(String name) {
    ensureOpen();
    if (!_libraryRepository.isOpen) {
      throw StateError('Library database is not open');
    }
    return _mapPlaylist(_playlistRepository.createPlaylist(name));
  }

  void deletePlaylist(String id) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return;
    _playlistRepository.deletePlaylist(id);
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return;
    _playlistRepository.addTrack(playlistId, trackId);
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return;
    _playlistRepository.removeTrack(playlistId, trackId);
  }

  bool isTrackInPlaylist(String playlistId, String trackId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return false;
    return _playlistRepository.isTrackInPlaylist(playlistId, trackId);
  }

  Set<String> getPlaylistIdsContainingTrack(String trackId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return {};
    return _playlistRepository.getPlaylistIdsContainingTrack(trackId);
  }

  bool isFavorite(String trackId) {
    return isTrackInPlaylist(kFavoritesPlaylistId, trackId);
  }

  bool toggleFavorite(String trackId) {
    ensureOpen();
    if (!_libraryRepository.isOpen) return false;
    if (isFavorite(trackId)) {
      _playlistRepository.removeTrack(kFavoritesPlaylistId, trackId);
      return false;
    }
    _playlistRepository.addTrack(kFavoritesPlaylistId, trackId);
    return true;
  }

  Playlist _mapPlaylist(PlaylistRecord record) {
    return Playlist(
      id: record.id,
      name: record.name,
      trackCount: _playlistRepository.getTrackCount(record.id),
      isSystem: record.isSystem,
    );
  }
}
