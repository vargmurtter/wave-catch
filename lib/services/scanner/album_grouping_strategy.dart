enum AlbumGroupingStrategy {
  byAlbumArtist,
  byFolder,
  byAlbumTitle,
}

extension AlbumGroupingStrategyLabels on AlbumGroupingStrategy {
  String get label => switch (this) {
        AlbumGroupingStrategy.byAlbumArtist => 'По тегам (Album Artist)',
        AlbumGroupingStrategy.byFolder => 'По папке на диске',
        AlbumGroupingStrategy.byAlbumTitle => 'По названию альбома',
      };

  String get description => switch (this) {
        AlbumGroupingStrategy.byAlbumArtist =>
          'Альбом определяется исполнителем альбома из тегов файла и его '
          'названием. Треки с приглашёнными артистами (feat.) останутся в '
          'одном альбоме, если в файлах указан Album Artist.',
        AlbumGroupingStrategy.byFolder =>
          'Треки из одной папки с одинаковым названием альбома считаются '
          'одним альбомом. Подходит, если музыка аккуратно разложена по '
          'папкам на диске.',
        AlbumGroupingStrategy.byAlbumTitle =>
          'Все треки с одинаковым названием альбома объединяются в один. '
          'Удобно для сборников и библиотек с неоднородными тегами. '
          'Внимание: может объединить разные релизы с одинаковым названием.',
      };

  bool get isRecommended => this == AlbumGroupingStrategy.byAlbumArtist;

  String toJson() => name;

  static AlbumGroupingStrategy fromJson(String? value) {
    return AlbumGroupingStrategy.values.firstWhere(
      (strategy) => strategy.name == value,
      orElse: () => AlbumGroupingStrategy.byAlbumArtist,
    );
  }
}
