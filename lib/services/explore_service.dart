import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/ytm_innertube_repository.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/models/track.dart';

class ExploreRecommendations {
  const ExploreRecommendations({
    this.recommended = const [],
    this.similar = const [],
    this.libraryEmpty = false,
  });

  final List<ExploreTrack> recommended;
  final List<ExploreTrack> similar;
  final bool libraryEmpty;
}

class ExploreService {
  ExploreService({
    required YtmInnerTubeRepository ytmRepository,
    required LibraryService libraryService,
    required LibraryRepository libraryRepository,
    required ImportSourceRepository Function() importSourceRepositoryFactory,
  })  : _ytmRepository = ytmRepository,
        _libraryService = libraryService,
        _libraryRepository = libraryRepository,
        _importSourceRepositoryFactory = importSourceRepositoryFactory;

  final YtmInnerTubeRepository _ytmRepository;
  final LibraryService _libraryService;
  final LibraryRepository _libraryRepository;
  final ImportSourceRepository Function() _importSourceRepositoryFactory;

  Future<List<ExploreTrack>> search(String query) {
    return _ytmRepository.searchSongs(query);
  }

  Future<ExploreSearchSuggestions> suggestions(String query) {
    return _ytmRepository.searchSuggestions(query);
  }

  bool isAlreadySaved(String videoId) {
    if (!_libraryRepository.isOpen) return false;
    return _importSourceRepositoryFactory().getByVideoId(videoId) != null;
  }

  Set<String> savedVideoIds() {
    if (!_libraryRepository.isOpen) return {};
    return _importSourceRepositoryFactory().getAllVideoIds();
  }

  Future<ExploreRecommendations> getRecommendations() async {
    final tracks = _libraryService.getAllTracks();
    if (tracks.isEmpty) {
      return const ExploreRecommendations(libraryEmpty: true);
    }

    final savedIds = savedVideoIds();
    final artistCounts = <String, ({String name, int count})>{};
    for (final track in tracks) {
      final entry = artistCounts[track.artistId];
      if (entry == null) {
        artistCounts[track.artistId] = (name: track.artist, count: 1);
      } else {
        artistCounts[track.artistId] = (
          name: entry.name,
          count: entry.count + 1,
        );
      }
    }

    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    final recommended = <ExploreTrack>[];
    final knownVideoIds = <String>{...savedIds};

    for (final entry in topArtists.take(3)) {
      final topSongs = await _ytmRepository.getArtistTopSongs(entry.key);
      for (final song in topSongs) {
        if (knownVideoIds.contains(song.videoId)) continue;
        recommended.add(song);
        knownVideoIds.add(song.videoId);
        if (recommended.length >= 8) break;
      }
      if (recommended.length >= 8) break;
    }

    final seedVideoId = await _resolveSeedVideoId(tracks, savedIds);
    final similar = seedVideoId != null
        ? (await _ytmRepository.getUpNexts(seedVideoId))
            .where((t) => !savedIds.contains(t.videoId))
            .take(12)
            .toList()
        : <ExploreTrack>[];

    return ExploreRecommendations(
      recommended: recommended,
      similar: similar,
    );
  }

  Future<String?> _resolveSeedVideoId(
    List<Track> tracks,
    Set<String> savedIds,
  ) async {
    if (!_libraryRepository.isOpen) return null;
    final importRepo = _importSourceRepositoryFactory();
    for (final record in importRepo.getAll()) {
      return record.videoId;
    }

    final seed = tracks.first;
    final results = await _ytmRepository.searchSongs('${seed.artist} ${seed.title}');
    if (results.isEmpty) return null;
    return results.first.videoId;
  }
}
