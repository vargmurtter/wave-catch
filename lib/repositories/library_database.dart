import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:music_player/services/scanner/scan_rules.dart';

class LibraryDatabase {
  LibraryDatabase(this._db, this.musicRoot);

  final Database _db;
  final String musicRoot;

  Database get db => _db;

  static LibraryDatabase open(String musicRoot) {
    final dbPath = p.join(musicRoot, kAppDataDirName, kLibraryDbFileName);
    final dbDir = Directory(p.dirname(dbPath));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final db = sqlite3.open(dbPath);
    final instance = LibraryDatabase(db, musicRoot);
    instance._migrate();
    return instance;
  }

  void close() {
    _db.dispose();
  }

  void _migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS library_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS artists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cover_path TEXT
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS albums (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist_id TEXT NOT NULL REFERENCES artists(id),
        year INTEGER,
        cover_path TEXT
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS tracks (
        id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        artist_id TEXT NOT NULL REFERENCES artists(id),
        album_id TEXT NOT NULL REFERENCES albums(id),
        duration_ms INTEGER NOT NULL DEFAULT 0,
        track_number INTEGER,
        genre TEXT,
        format TEXT,
        bitrate INTEGER,
        cover_path TEXT,
        file_modified_ms INTEGER,
        indexed_at_ms INTEGER NOT NULL
      )
    ''');

    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(album_id)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artist ON tracks(artist_id)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_albums_artist ON albums(artist_id)',
    );

    final version = int.tryParse(_getMeta('schema_version') ?? '1') ?? 1;
    if (version < 2) {
      _migrateToV2();
    }
    if (version < 3) {
      _migrateToV3();
    }
    if (version < 4) {
      _migrateToV4();
    }
    if (version < 5) {
      _migrateToV5();
    }
    if (version < 6) {
      _migrateToV6();
    }

    _setMeta('schema_version', kLibrarySchemaVersion.toString());
    _setMeta('root_path', musicRoot);
  }

  String? _getMeta(String key) {
    final rows = _db.select(
      'SELECT value FROM library_meta WHERE key = ?',
      [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  void _migrateToV2() {
    for (final statement in [
      'ALTER TABLE tracks ADD COLUMN featured_artists TEXT',
      'ALTER TABLE tracks ADD COLUMN album_artist TEXT',
      'ALTER TABLE tracks ADD COLUMN disc_number INTEGER',
    ]) {
      try {
        _db.execute(statement);
      } catch (_) {
        // Column may already exist.
      }
    }
  }

  void _migrateToV3() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS import_sources (
        video_id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL UNIQUE,
        saved_at_ms INTEGER NOT NULL
      )
    ''');
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_import_sources_path ON import_sources(file_path)',
    );
  }

  void _migrateToV4() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        created_at_ms INTEGER NOT NULL
      )
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS playlist_tracks (
        playlist_id TEXT NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
        track_id TEXT NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
        added_at_ms INTEGER NOT NULL,
        PRIMARY KEY (playlist_id, track_id)
      )
    ''');
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_playlist_tracks_playlist ON playlist_tracks(playlist_id)',
    );
    _db.execute(
      '''
      INSERT OR IGNORE INTO playlists (id, name, is_system, created_at_ms)
      VALUES (?, 'Favorites', 1, ?)
      ''',
      [kFavoritesPlaylistId, DateTime.now().millisecondsSinceEpoch],
    );
  }

  void _migrateToV5() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      '''
      INSERT OR IGNORE INTO playlists (id, name, is_system, created_at_ms)
      VALUES (?, 'Saved', 1, ?)
      ''',
      [kSavedFromExplorePlaylistId, now],
    );
    _db.execute(
      '''
      INSERT OR IGNORE INTO playlist_tracks (playlist_id, track_id, added_at_ms)
      SELECT ?, t.id, i.saved_at_ms
      FROM import_sources i
      JOIN tracks t ON t.file_path = i.file_path
      ''',
      [kSavedFromExplorePlaylistId],
    );
  }

  void _migrateToV6() {
    try {
      _db.execute(
        '''
        ALTER TABLE playlists
        ADD COLUMN added_at_sort_asc INTEGER NOT NULL DEFAULT 1
        ''',
      );
    } catch (_) {
      // Column may already exist.
    }
  }

  void _setMeta(String key, String value) {
    _db.execute(
      'INSERT OR REPLACE INTO library_meta (key, value) VALUES (?, ?)',
      [key, value],
    );
  }

  void setLastScanAt(DateTime time) {
    _setMeta('last_scan_at', time.millisecondsSinceEpoch.toString());
  }

  String embeddedCoversDir() {
    return p.join(musicRoot, kAppDataDirName, kEmbeddedCoversDirName);
  }

  void ensureEmbeddedCoversDir() {
    final dir = Directory(embeddedCoversDir());
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }
}
