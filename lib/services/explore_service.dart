import 'package:music_player/repositories/import_source_repository.dart';
import 'package:music_player/repositories/library_repository.dart';
import 'package:music_player/repositories/ytm_innertube_repository.dart';
import 'package:music_player/services/library_service.dart';
import 'package:music_player/ui/models/explore_track.dart';

class ExploreRecommendations {
  const ExploreRecommendations({
    this.youMightLike = const [],
    this.libraryEmpty = false,
    this.noExploreImports = false,
  });

  final List<ExploreTrack> youMightLike;
  final bool libraryEmpty;
  final bool noExploreImports;
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

  static const _maxSeeds = 5;
  static const _maxResults = 30;

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

    if (!_libraryRepository.isOpen) {
      return const ExploreRecommendations(noExploreImports: true);
    }

    final seedVideoIds = _importSourceRepositoryFactory()
        .getAll()
        .take(_maxSeeds)
        .map((record) => record.videoId)
        .toList();

    if (seedVideoIds.isEmpty) {
      return const ExploreRecommendations(noExploreImports: true);
    }

    final savedIds = savedVideoIds();
    final excludeIds = {...savedIds, ...seedVideoIds};
    final upNextLists = await Future.wait(
      seedVideoIds.map(_ytmRepository.getUpNexts),
    );

    final youMightLike = _mergeUpNexts(
      upNextLists: upNextLists,
      excludeIds: excludeIds,
      maxResults: _maxResults,
    );

    return ExploreRecommendations(youMightLike: youMightLike);
  }

  List<ExploreTrack> _mergeUpNexts({
    required List<List<ExploreTrack>> upNextLists,
    required Set<String> excludeIds,
    required int maxResults,
  }) {
    final results = <ExploreTrack>[];
    final seen = Set<String>.from(excludeIds);
    final indices = List<int>.filled(upNextLists.length, 0);
    var hasMore = true;

    while (hasMore && results.length < maxResults) {
      hasMore = false;
      for (var i = 0; i < upNextLists.length; i++) {
        final list = upNextLists[i];
        while (indices[i] < list.length) {
          final track = list[indices[i]++];
          if (seen.add(track.videoId)) {
            results.add(track);
            if (results.length >= maxResults) return results;
            break;
          }
        }
        if (indices[i] < list.length) hasMore = true;
      }
    }

    return results;
  }
}
