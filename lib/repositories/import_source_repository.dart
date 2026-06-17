import 'package:music_player/repositories/library_database.dart';
import 'package:music_player/repositories/library_repository.dart';

class ImportSourceRecord {
  const ImportSourceRecord({
    required this.videoId,
    required this.filePath,
    required this.savedAtMs,
  });

  final String videoId;
  final String filePath;
  final int savedAtMs;
}

class ImportSourceRepository {
  ImportSourceRepository(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  LibraryDatabase get _database => _libraryRepository.requireDatabase;

  ImportSourceRecord? getByVideoId(String videoId) {
    final rows = _database.db.select(
      'SELECT video_id, file_path, saved_at_ms FROM import_sources WHERE video_id = ?',
      [videoId],
    );
    if (rows.isEmpty) return null;
    return _map(rows.first);
  }

  ImportSourceRecord? getByFilePath(String filePath) {
    final rows = _database.db.select(
      'SELECT video_id, file_path, saved_at_ms FROM import_sources WHERE file_path = ?',
      [filePath],
    );
    if (rows.isEmpty) return null;
    return _map(rows.first);
  }

  List<ImportSourceRecord> getAll() {
    final rows = _database.db.select(
      'SELECT video_id, file_path, saved_at_ms FROM import_sources ORDER BY saved_at_ms DESC',
    );
    return rows.map(_map).toList();
  }

  Set<String> getAllVideoIds() {
    final rows = _database.db.select('SELECT video_id FROM import_sources');
    return rows.map((row) => row['video_id'] as String).toSet();
  }

  void upsert(ImportSourceRecord record) {
    _database.db.execute(
      '''
      INSERT INTO import_sources (video_id, file_path, saved_at_ms)
      VALUES (?, ?, ?)
      ON CONFLICT(video_id) DO UPDATE SET
        file_path = excluded.file_path,
        saved_at_ms = excluded.saved_at_ms
      ''',
      [record.videoId, record.filePath, record.savedAtMs],
    );
  }

  ImportSourceRecord _map(dynamic row) {
    return ImportSourceRecord(
      videoId: row['video_id'] as String,
      filePath: row['file_path'] as String,
      savedAtMs: row['saved_at_ms'] as int,
    );
  }
}
