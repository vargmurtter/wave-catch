enum PlaylistSortOrder {
  asc,
  desc,
}

extension PlaylistSortOrderStorage on PlaylistSortOrder {
  bool get isAscending => this == PlaylistSortOrder.asc;

  static PlaylistSortOrder fromAscending(bool ascending) {
    return ascending ? PlaylistSortOrder.asc : PlaylistSortOrder.desc;
  }
}
