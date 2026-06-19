import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/services/scanner/id_generator.dart';
import 'package:music_player/services/scanner/scan_rules.dart';

void main() {
  late Directory tempDir;
  late LibraryRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wave_catcher_sync_test_');
    repository = LibraryRepository()..open(tempDir.path);
  });

  tearDown(() {
    repository.close();
    tempDir.deleteSync(recursive: true);
  });

  TrackRecord trackRecord({
    required String filePath,
    required String title,
    required String artistName,
    required String albumTitle,
    String? albumId,
  }) {
    final artistId = artistIdFor(artistName);
    final resolvedAlbumId =
        albumId ?? albumIdFor(artistName, albumTitle);
    return TrackRecord(
      id: trackIdFor(filePath),
      filePath: filePath,
      title: title,
      artistId: artistId,
      albumId: resolvedAlbumId,
      durationMs: 180000,
      indexedAtMs: 1,
    );
  }

  ArtistRecord artistRecord(String name) {
    return ArtistRecord(id: artistIdFor(name), name: name);
  }

  AlbumRecord albumRecord({
    required String title,
    required String artistName,
    String? id,
  }) {
    final artistId = artistIdFor(artistName);
    return AlbumRecord(
      id: id ?? albumIdFor(artistName, title),
      title: title,
      artistId: artistId,
    );
  }

  void sync({
    required List<TrackRecord> tracks,
    required List<ArtistRecord> artists,
    required List<AlbumRecord> albums,
  }) {
    repository.syncLibrary(
      artists: artists,
      albums: albums,
      tracks: tracks,
      scannedFilePaths: tracks.map((track) => track.filePath).toSet(),
    );
  }

  group('syncLibrary', () {
    test('preserves playlist_tracks for tracks still on disk', () {
      const filePath = '/music/artist/song.mp3';
      const artistName = 'Artist';
      const albumTitle = 'Album';
      final track = trackRecord(
        filePath: filePath,
        title: 'Song',
        artistName: artistName,
        albumTitle: albumTitle,
      );

      repository.upsertArtist(artistRecord(artistName));
      repository.upsertAlbum(
        albumRecord(title: albumTitle, artistName: artistName),
      );
      repository.upsertTrack(track);
      repository.playlistRepository.addTrack(kFavoritesPlaylistId, track.id);

      sync(
        tracks: [track],
        artists: [artistRecord(artistName)],
        albums: [
          albumRecord(title: albumTitle, artistName: artistName),
        ],
      );

      expect(repository.getTrackById(track.id), isNotNull);
      expect(
        repository.playlistRepository.getTrackIdsForPlaylist(
          kFavoritesPlaylistId,
        ),
        [track.id],
      );
      expect(
        repository.playlistRepository.isTrackInPlaylist(
          kFavoritesPlaylistId,
          track.id,
        ),
        isTrue,
      );
    });

    test('removes missing tracks, playlist links, and import_sources', () {
      const filePath = '/music/imports/song.mp3';
      const artistName = 'Artist';
      const albumTitle = 'Singles';
      final track = trackRecord(
        filePath: filePath,
        title: 'Song',
        artistName: artistName,
        albumTitle: albumTitle,
      );

      repository.upsertArtist(artistRecord(artistName));
      repository.upsertAlbum(
        albumRecord(title: albumTitle, artistName: artistName),
      );
      repository.upsertTrack(track);
      repository.playlistRepository.addTrack(
        kSavedFromExplorePlaylistId,
        track.id,
      );
      repository.importSourceRepository.upsert(
        ImportSourceRecord(
          videoId: 'video123',
          filePath: filePath,
          savedAtMs: 1000,
        ),
      );

      repository.syncLibrary(
        artists: const [],
        albums: const [],
        tracks: const [],
        scannedFilePaths: const {},
      );

      expect(repository.getTrackById(track.id), isNull);
      expect(
        repository.playlistRepository.getTrackIdsForPlaylist(
          kSavedFromExplorePlaylistId,
        ),
        isEmpty,
      );
      expect(
        repository.importSourceRepository.getByVideoId('video123'),
        isNull,
      );
    });

    test('updates album assignment and deletes orphaned albums', () {
      const filePath = '/music/artist/song.mp3';
      const artistName = 'Artist';
      const oldAlbumTitle = 'Old Album';
      const newAlbumTitle = 'New Album';
      final oldAlbumId = albumIdFor(artistName, oldAlbumTitle);
      final newAlbumId = albumIdFor(artistName, newAlbumTitle);
      final track = trackRecord(
        filePath: filePath,
        title: 'Song',
        artistName: artistName,
        albumTitle: oldAlbumTitle,
        albumId: oldAlbumId,
      );

      repository.upsertArtist(artistRecord(artistName));
      repository.upsertAlbum(
        albumRecord(
          title: oldAlbumTitle,
          artistName: artistName,
          id: oldAlbumId,
        ),
      );
      repository.upsertTrack(track);

      final updatedTrack = TrackRecord(
        id: track.id,
        filePath: filePath,
        title: 'Song',
        artistId: track.artistId,
        albumId: newAlbumId,
        durationMs: track.durationMs,
        indexedAtMs: track.indexedAtMs,
      );

      sync(
        tracks: [updatedTrack],
        artists: [artistRecord(artistName)],
        albums: [
          albumRecord(
            title: newAlbumTitle,
            artistName: artistName,
            id: newAlbumId,
          ),
        ],
      );

      expect(repository.getTrackById(track.id)?.albumId, newAlbumId);
      expect(repository.getAlbumById(oldAlbumId), isNull);
      expect(repository.getAlbumById(newAlbumId), isNotNull);
    });

    test('cleans dangling playlist_tracks after track removal', () {
      const filePath = '/music/artist/song.mp3';
      const artistName = 'Artist';
      const albumTitle = 'Album';
      final track = trackRecord(
        filePath: filePath,
        title: 'Song',
        artistName: artistName,
        albumTitle: albumTitle,
      );
      const playlistId = 'user_playlist';

      repository.requireDatabase.db.execute(
        '''
        INSERT INTO playlists (id, name, is_system, created_at_ms, added_at_sort_asc)
        VALUES (?, 'User', 0, 1, 1)
        ''',
        [playlistId],
      );
      repository.upsertArtist(artistRecord(artistName));
      repository.upsertAlbum(
        albumRecord(title: albumTitle, artistName: artistName),
      );
      repository.upsertTrack(track);
      repository.playlistRepository.addTrack(playlistId, track.id);

      repository.syncLibrary(
        artists: const [],
        albums: const [],
        tracks: const [],
        scannedFilePaths: const {},
      );

      final rows = repository.requireDatabase.db.select(
        'SELECT COUNT(*) AS count FROM playlist_tracks',
      );
      expect(rows.first['count'], 0);
      expect(
        repository.playlistRepository.getTrackCount(playlistId),
        0,
      );
    });
  });
}
