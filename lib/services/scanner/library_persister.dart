import 'package:music_player/repositories/entities/library_entities.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/services/scanner/cover_art_resolver.dart';

class LibraryPersister {
  LibraryPersister(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  void persist(ResolvedLibrary library) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final artists = library.artists
        .map(
          (artist) => ArtistRecord(
            id: artist.id,
            name: artist.name,
            coverPath: artist.coverPath,
          ),
        )
        .toList();

    final albums = library.albums
        .map(
          (album) => AlbumRecord(
            id: album.id,
            title: album.title,
            artistId: album.artistId,
            year: album.year,
            coverPath: album.coverPath,
          ),
        )
        .toList();

    final tracks = library.tracks
        .map(
          (item) => TrackRecord(
            id: item.track.id,
            filePath: item.track.filePath,
            title: item.track.title,
            artistId: item.track.artistId,
            albumId: item.track.albumId,
            durationMs: item.track.durationMs,
            indexedAtMs: now,
            trackNumber: item.track.trackNumber,
            genre: item.track.genre,
            format: item.track.format,
            coverPath: item.coverPath,
            fileModifiedMs: item.track.fileModifiedMs,
          ),
        )
        .toList();

    _libraryRepository.replaceLibrary(
      artists: artists,
      albums: albums,
      tracks: tracks,
      scannedFilePaths: tracks.map((track) => track.filePath).toSet(),
    );
  }
}
