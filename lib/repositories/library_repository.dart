import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/library_database.dart';
import 'package:music_player/repositories/playlist_repository.dart';
import 'package:music_player/services/metadata/track_metadata_override.dart';

class LibraryRepository {
  LibraryDatabase? _database;

  bool get isOpen => _database != null;

  String? get musicRoot => _database?.musicRoot;

  void open(String musicRoot) {
    final normalized = p.normalize(musicRoot);
    if (_database != null &&
        p.normalize(_database!.musicRoot) == normalized) {
      return;
    }
    close();
    _database = LibraryDatabase.open(normalized);
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

  static const _trackColumns = '''
    id, file_path, title, artist_id, album_id, duration_ms,
    track_number, genre, format, bitrate, cover_path,
    file_modified_ms, indexed_at_ms, featured_artists, album_artist, disc_number
  ''';

  LibraryDatabase get requireDatabase => _db;

  ImportSourceRepository get importSourceRepository =>
      ImportSourceRepository(this);

  PlaylistRepository get playlistRepository => PlaylistRepository(this);

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
      'SELECT $_trackColumns FROM tracks WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapTrack(rows.first);
  }

  List<TrackRecord> getTracksForAlbum(String albumId) {
    final rows = _db.db.select(
      '''
      SELECT $_trackColumns
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
      SELECT $_trackColumns
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

  TrackRecord? getTrackByFilePath(String filePath) {
    final rows = _db.db.select(
      'SELECT $_trackColumns FROM tracks WHERE file_path = ?',
      [filePath],
    );
    if (rows.isEmpty) return null;
    return _mapTrack(rows.first);
  }

  List<TrackRecord> getAllTracks() {
    final rows = _db.db.select(
      '''
      SELECT $_trackColumns
      FROM tracks
      ORDER BY title
      ''',
    );
    return rows.map(_mapTrack).toList();
  }

  List<TrackRecord> getRecentlyAddedTracks({int limit = 10}) {
    final rows = _db.db.select(
      '''
      SELECT $_trackColumns
      FROM tracks
      ORDER BY indexed_at_ms DESC
      LIMIT ?
      ''',
      [limit],
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

  void upsertArtist(ArtistRecord artist) {
    _db.db.execute(
      '''
      INSERT INTO artists (id, name, cover_path)
      VALUES (?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        name = excluded.name,
        cover_path = COALESCE(excluded.cover_path, artists.cover_path)
      ''',
      [artist.id, artist.name, artist.coverPath],
    );
  }

  void upsertAlbum(AlbumRecord album) {
    _db.db.execute(
      '''
      INSERT INTO albums (id, title, artist_id, year, cover_path)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title = excluded.title,
        artist_id = excluded.artist_id,
        year = COALESCE(excluded.year, albums.year),
        cover_path = COALESCE(excluded.cover_path, albums.cover_path)
      ''',
      [album.id, album.title, album.artistId, album.year, album.coverPath],
    );
  }

  void updateTrack(TrackRecord track) {
    _db.db.execute(
      '''
      UPDATE tracks SET
        title = ?,
        artist_id = ?,
        album_id = ?,
        track_number = ?,
        genre = ?,
        cover_path = ?,
        featured_artists = ?,
        album_artist = ?,
        disc_number = ?
      WHERE id = ?
      ''',
      [
        track.title,
        track.artistId,
        track.albumId,
        track.trackNumber,
        track.genre,
        track.coverPath,
        encodeFeaturedArtists(track.featuredArtists),
        track.albumArtist,
        track.discNumber,
        track.id,
      ],
    );
  }

  void upsertTrack(TrackRecord track) {
    _db.db.execute(
      '''
      INSERT INTO tracks (
        id, file_path, title, artist_id, album_id, duration_ms,
        track_number, genre, format, bitrate, cover_path,
        file_modified_ms, indexed_at_ms, featured_artists, album_artist,
        disc_number
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        file_path = excluded.file_path,
        title = excluded.title,
        artist_id = excluded.artist_id,
        album_id = excluded.album_id,
        duration_ms = excluded.duration_ms,
        track_number = excluded.track_number,
        genre = excluded.genre,
        format = excluded.format,
        bitrate = excluded.bitrate,
        cover_path = excluded.cover_path,
        file_modified_ms = excluded.file_modified_ms,
        indexed_at_ms = excluded.indexed_at_ms,
        featured_artists = excluded.featured_artists,
        album_artist = excluded.album_artist,
        disc_number = excluded.disc_number
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
        encodeFeaturedArtists(track.featuredArtists),
        track.albumArtist,
        track.discNumber,
      ],
    );
  }

  void deleteOrphanedArtistsAndAlbums() {
    _db.db.execute('''
      DELETE FROM artists
      WHERE id NOT IN (SELECT DISTINCT artist_id FROM tracks)
        AND id NOT IN (SELECT DISTINCT artist_id FROM albums)
    ''');
    _db.db.execute('''
      DELETE FROM albums
      WHERE id NOT IN (SELECT DISTINCT album_id FROM tracks)
    ''');
  }

  void syncLibrary({
    required List<ArtistRecord> artists,
    required List<AlbumRecord> albums,
    required List<TrackRecord> tracks,
    required Set<String> scannedFilePaths,
  }) {
    final db = _db.db;
    db.execute('BEGIN IMMEDIATE');

    try {
      for (final artist in artists) {
        upsertArtist(artist);
      }

      for (final album in albums) {
        upsertAlbum(album);
      }

      for (final track in tracks) {
        upsertTrack(track);
      }

      final existingRows = db.select('SELECT id, file_path FROM tracks');
      for (final row in existingRows) {
        final filePath = row['file_path'] as String;
        if (!scannedFilePaths.contains(filePath)) {
          db.execute('DELETE FROM tracks WHERE id = ?', [row['id'] as String]);
        }
      }

      deleteOrphanedArtistsAndAlbums();
      _deleteOrphanPlaylistTracks();
      _deleteOrphanImportSources();

      _db.setLastScanAt(DateTime.now());
      db.execute('COMMIT');
    } catch (error) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  void _deleteOrphanPlaylistTracks() {
    _db.db.execute('''
      DELETE FROM playlist_tracks
      WHERE track_id NOT IN (SELECT id FROM tracks)
    ''');
  }

  void _deleteOrphanImportSources() {
    _db.db.execute('''
      DELETE FROM import_sources
      WHERE file_path NOT IN (SELECT file_path FROM tracks)
    ''');
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
      featuredArtists: decodeFeaturedArtists(row['featured_artists'] as String?),
      albumArtist: row['album_artist'] as String?,
      discNumber: row['disc_number'] as int?,
    );
  }
}
