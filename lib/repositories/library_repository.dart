import 'package:sqlite3/sqlite3.dart';

import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/library_database.dart';

class LibraryRepository {
  LibraryDatabase? _database;

  bool get isOpen => _database != null;

  String? get musicRoot => _database?.musicRoot;

  void open(String musicRoot) {
    close();
    _database = LibraryDatabase.open(musicRoot);
  }

  void close() {
    _database?.close();
    _database = null;
  }

  LibraryDatabase get _db {
    final database = _database;
    if (database == null) {
      throw StateError('Library database is not open');
    }
    return database;
  }

  List<ArtistRecord> getArtists() {
    final rows = _db.db.select('SELECT id, name, cover_path FROM artists ORDER BY name');
    return rows.map(_mapArtist).toList();
  }

  List<AlbumRecord> getAlbums() {
    final rows = _db.db.select(
      'SELECT id, title, artist_id, year, cover_path FROM albums ORDER BY title',
    );
    return rows.map(_mapAlbum).toList();
  }

  ArtistRecord? getArtistById(String id) {
    final rows = _db.db.select(
      'SELECT id, name, cover_path FROM artists WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapArtist(rows.first);
  }

  AlbumRecord? getAlbumById(String id) {
    final rows = _db.db.select(
      'SELECT id, title, artist_id, year, cover_path FROM albums WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapAlbum(rows.first);
  }

  TrackRecord? getTrackById(String id) {
    final rows = _db.db.select(
      '''
      SELECT id, file_path, title, artist_id, album_id, duration_ms,
             track_number, genre, format, bitrate, cover_path,
             file_modified_ms, indexed_at_ms
      FROM tracks WHERE id = ?
      ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapTrack(rows.first);
  }

  List<TrackRecord> getTracksForAlbum(String albumId) {
    final rows = _db.db.select(
      '''
      SELECT id, file_path, title, artist_id, album_id, duration_ms,
             track_number, genre, format, bitrate, cover_path,
             file_modified_ms, indexed_at_ms
      FROM tracks WHERE album_id = ?
      ORDER BY track_number, title
      ''',
      [albumId],
    );
    return rows.map(_mapTrack).toList();
  }

  List<TrackRecord> getTracksForArtist(String artistId) {
    final rows = _db.db.select(
      '''
      SELECT id, file_path, title, artist_id, album_id, duration_ms,
             track_number, genre, format, bitrate, cover_path,
             file_modified_ms, indexed_at_ms
      FROM tracks WHERE artist_id = ?
      ORDER BY title
      ''',
      [artistId],
    );
    return rows.map(_mapTrack).toList();
  }

  List<AlbumRecord> getAlbumsForArtist(String artistId) {
    final rows = _db.db.select(
      '''
      SELECT id, title, artist_id, year, cover_path
      FROM albums WHERE artist_id = ?
      ORDER BY year DESC, title
      ''',
      [artistId],
    );
    return rows.map(_mapAlbum).toList();
  }

  List<TrackRecord> getAllTracks() {
    final rows = _db.db.select(
      '''
      SELECT id, file_path, title, artist_id, album_id, duration_ms,
             track_number, genre, format, bitrate, cover_path,
             file_modified_ms, indexed_at_ms
      FROM tracks
      ORDER BY title
      ''',
    );
    return rows.map(_mapTrack).toList();
  }

  List<ArtistRecord> searchArtists(String query, {int limit = 20}) {
    final normalizedQuery = _normalizeQueryInput(query);
    if (normalizedQuery.isEmpty) return [];

    return getArtists()
        .where((artist) => _containsQuery(artist.name, normalizedQuery))
        .take(limit)
        .toList();
  }

  List<AlbumRecord> searchAlbums(String query, {int limit = 20}) {
    final normalizedQuery = _normalizeQueryInput(query);
    if (normalizedQuery.isEmpty) return [];

    final artistNames = {
      for (final artist in getArtists()) artist.id: artist.name,
    };

    return getAlbums()
        .where((album) {
          return _containsQuery(album.title, normalizedQuery) ||
              _containsQuery(
                artistNames[album.artistId] ?? '',
                normalizedQuery,
              );
        })
        .take(limit)
        .toList();
  }

  List<TrackRecord> searchTracks(String query, {int limit = 20}) {
    final normalizedQuery = _normalizeQueryInput(query);
    if (normalizedQuery.isEmpty) return [];

    final artistNames = {
      for (final artist in getArtists()) artist.id: artist.name,
    };
    final albumTitles = {
      for (final album in getAlbums()) album.id: album.title,
    };

    return getAllTracks()
        .where((track) {
          return _containsQuery(track.title, normalizedQuery) ||
              _containsQuery(
                artistNames[track.artistId] ?? '',
                normalizedQuery,
              ) ||
              _containsQuery(
                albumTitles[track.albumId] ?? '',
                normalizedQuery,
              );
        })
        .take(limit)
        .toList();
  }

  List<AlbumRecord> getOtherAlbumsByArtist(
    String artistId, {
    required String excludeAlbumId,
  }) {
    final rows = _db.db.select(
      '''
      SELECT id, title, artist_id, year, cover_path
      FROM albums WHERE artist_id = ? AND id != ?
      ORDER BY year DESC, title
      ''',
      [artistId, excludeAlbumId],
    );
    return rows.map(_mapAlbum).toList();
  }

  void replaceLibrary({
    required List<ArtistRecord> artists,
    required List<AlbumRecord> albums,
    required List<TrackRecord> tracks,
    required Set<String> scannedFilePaths,
  }) {
    final db = _db.db;
    db.execute('BEGIN IMMEDIATE');

    try {
      db.execute('DELETE FROM tracks');
      db.execute('DELETE FROM albums');
      db.execute('DELETE FROM artists');

      for (final artist in artists) {
        db.execute(
          'INSERT INTO artists (id, name, cover_path) VALUES (?, ?, ?)',
          [artist.id, artist.name, artist.coverPath],
        );
      }

      for (final album in albums) {
        db.execute(
          '''
          INSERT INTO albums (id, title, artist_id, year, cover_path)
          VALUES (?, ?, ?, ?, ?)
          ''',
          [album.id, album.title, album.artistId, album.year, album.coverPath],
        );
      }

      for (final track in tracks) {
        db.execute(
          '''
          INSERT INTO tracks (
            id, file_path, title, artist_id, album_id, duration_ms,
            track_number, genre, format, bitrate, cover_path,
            file_modified_ms, indexed_at_ms
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            track.id,
            track.filePath,
            track.title,
            track.artistId,
            track.albumId,
            track.durationMs,
            track.trackNumber,
            track.genre,
            track.format,
            track.bitrate,
            track.coverPath,
            track.fileModifiedMs,
            track.indexedAtMs,
          ],
        );
      }

      _db.setLastScanAt(DateTime.now());
      db.execute('COMMIT');
    } catch (error) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  static String _normalizeQueryInput(String query) {
    return query.trim().replaceAll('%', '').replaceAll('_', '').toLowerCase();
  }

  static bool _containsQuery(String value, String normalizedQuery) {
    return value.toLowerCase().contains(normalizedQuery);
  }

  ArtistRecord _mapArtist(Row row) {
    return ArtistRecord(
      id: row['id'] as String,
      name: row['name'] as String,
      coverPath: row['cover_path'] as String?,
    );
  }

  AlbumRecord _mapAlbum(Row row) {
    return AlbumRecord(
      id: row['id'] as String,
      title: row['title'] as String,
      artistId: row['artist_id'] as String,
      year: row['year'] as int?,
      coverPath: row['cover_path'] as String?,
    );
  }

  TrackRecord _mapTrack(Row row) {
    return TrackRecord(
      id: row['id'] as String,
      filePath: row['file_path'] as String,
      title: row['title'] as String,
      artistId: row['artist_id'] as String,
      albumId: row['album_id'] as String,
      durationMs: row['duration_ms'] as int,
      trackNumber: row['track_number'] as int?,
      genre: row['genre'] as String?,
      format: row['format'] as String?,
      bitrate: row['bitrate'] as int?,
      coverPath: row['cover_path'] as String?,
      fileModifiedMs: row['file_modified_ms'] as int?,
      indexedAtMs: row['indexed_at_ms'] as int,
    );
  }
}
