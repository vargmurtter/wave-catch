sealed class LibraryRoute {
  const LibraryRoute();
}

class LibraryMainRoute extends LibraryRoute {
  const LibraryMainRoute();
}

class ArtistDetailRoute extends LibraryRoute {
  const ArtistDetailRoute(this.artistId);

  final String artistId;
}

class ArtistTracksRoute extends LibraryRoute {
  const ArtistTracksRoute(this.artistId);

  final String artistId;
}

class AlbumDetailRoute extends LibraryRoute {
  const AlbumDetailRoute(this.albumId);

  final String albumId;
}
