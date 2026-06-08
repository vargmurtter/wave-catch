enum AlbumGroupingStrategy {
  byAlbumArtist,
  byFolder,
  byAlbumTitle,
}

extension AlbumGroupingStrategyLabels on AlbumGroupingStrategy {
  bool get isRecommended => this == AlbumGroupingStrategy.byAlbumArtist;

  String toJson() => name;

  static AlbumGroupingStrategy fromJson(String? value) {
    return AlbumGroupingStrategy.values.firstWhere(
      (strategy) => strategy.name == value,
      orElse: () => AlbumGroupingStrategy.byAlbumArtist,
    );
  }
}
