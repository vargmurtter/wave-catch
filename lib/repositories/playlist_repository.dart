import 'package:music_player/repositories/library_database.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/services/scanner/id_generator.dart';

class PlaylistRecord {
  const PlaylistRecord({
    required this.id,
    required this.name,
    required this.isSystem,
    required this.createdAtMs,
  });

  final String id;
  final String name;
  final bool isSystem;
  final int createdAtMs;
}

class PlaylistRepository {
  PlaylistRepository(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  LibraryDatabase get _database => _libraryRepository.requireDatabase;

  List<PlaylistRecord> getPlaylists() {
    final rows = _database.db.select(
      '''
      SELECT p.id, p.name, p.is_system, p.created_at_ms,
             (SELECT COUNT(*) FROM playlist_tracks pt WHERE pt.playlist_id = p.id) AS track_count
      FROM playlists p
      ORDER BY p.is_system DESC, p.created_at_ms ASC
      ''',
    );
    return rows.map(_mapPlaylist).toList();
  }

  PlaylistRecord? getPlaylistById(String id) {
    final rows = _database.db.select(
      '''
      SELECT id, name, is_system, created_at_ms
      FROM playlists WHERE id = ?
      ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapPlaylist(rows.first);
  }

  PlaylistRecord createPlaylist(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty');
    }
    final id = hashId('playlist:${DateTime.now().microsecondsSinceEpoch}:$trimmed');
    final now = DateTime.now().millisecondsSinceEpoch;
    _database.db.execute(
      '''
      INSERT INTO playlists (id, name, is_system, created_at_ms)
      VALUES (?, ?, 0, ?)
      ''',
      [id, trimmed, now],
    );
    return PlaylistRecord(
      id: id,
      name: trimmed,
      isSystem: false,
      createdAtMs: now,
    );
  }

  void deletePlaylist(String id) {
    _database.db.execute(
      'DELETE FROM playlists WHERE id = ? AND is_system = 0',
      [id],
    );
  }

  List<String> getTrackIdsForPlaylist(String playlistId) {
    final rows = _database.db.select(
      '''
      SELECT track_id FROM playlist_tracks
      WHERE playlist_id = ?
      ORDER BY added_at_ms ASC
      ''',
      [playlistId],
    );
    return rows.map((row) => row['track_id'] as String).toList();
  }

  int getTrackCount(String playlistId) {
    final rows = _database.db.select(
      'SELECT COUNT(*) AS count FROM playlist_tracks WHERE playlist_id = ?',
      [playlistId],
    );
    return rows.first['count'] as int;
  }

  bool isTrackInPlaylist(String playlistId, String trackId) {
    final rows = _database.db.select(
      '''
      SELECT 1 FROM playlist_tracks
      WHERE playlist_id = ? AND track_id = ?
      ''',
      [playlistId, trackId],
    );
    return rows.isNotEmpty;
  }

  Set<String> getPlaylistIdsContainingTrack(String trackId) {
    final rows = _database.db.select(
      'SELECT playlist_id FROM playlist_tracks WHERE track_id = ?',
      [trackId],
    );
    return rows.map((row) => row['playlist_id'] as String).toSet();
  }

  void addTrack(String playlistId, String trackId) {
    _database.db.execute(
      '''
      INSERT OR IGNORE INTO playlist_tracks (playlist_id, track_id, added_at_ms)
      VALUES (?, ?, ?)
      ''',
      [playlistId, trackId, DateTime.now().millisecondsSinceEpoch],
    );
  }

  void removeTrack(String playlistId, String trackId) {
    _database.db.execute(
      'DELETE FROM playlist_tracks WHERE playlist_id = ? AND track_id = ?',
      [playlistId, trackId],
    );
  }

  PlaylistRecord _mapPlaylist(dynamic row) {
    return PlaylistRecord(
      id: row['id'] as String,
      name: row['name'] as String,
      isSystem: (row['is_system'] as int) != 0,
      createdAtMs: row['created_at_ms'] as int,
    );
  }
}
