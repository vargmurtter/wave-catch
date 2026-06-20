# Global library search

Search artists, albums, and tracks in the **local library** at once. Results appear in the content area when typing in the sidebar search field.

> YouTube Music search is separate, in **Explore** ([explore.md](explore.md)). The global sidebar field does not use the network.

## UX

- **Search** field — in the sidebar below the "Wave Catch" title, always available.
- With a non-empty query (`trim`), the content area shows `SearchScreen` instead of the current screen or detail route.
- Results grouped in three sections: **Artists**, **Albums**, **Tracks**. Empty sections are hidden.
- Query debounce: **200 ms**. While debounce is pending, "Searching…" is shown.
- Limit: **20 results** per category.

### Actions on selection

| Type | Action |
|------|--------|
| Artist | Clear route → artist screen |
| Album | Clear route → album screen |
| Track | Clear search → `playTrackInAlbum(track)` (queue = album) |

Query is cleared after selection.

## Layers

```
GlobalSearchField / SearchScreen (UI)
    ↓
searchQueryProvider, librarySearchResultsProvider (Riverpod)
    ↓
LibraryService.search()
    ↓
LibraryRepository.searchArtists / searchAlbums / searchTracks
    ↓
In-memory filtering via Dart toLowerCase() (Unicode)
```

## Search fields

| Category | Fields |
|----------|--------|
| Artists | `artists.name` |
| Albums | `albums.title`, `artists.name` |
| Tracks | `tracks.title`, `artists.name`, `albums.title` |

Special characters `%` and `_` are stripped from user input. Case-insensitive comparison: `toLowerCase()` in Dart (supports Cyrillic and Latin).

## Files

| File | Purpose |
|------|---------|
| `lib/repositories/library_repository.dart` | SQL search |
| `lib/services/library_service.dart` | `search()`, mapping to UI models |
| `lib/ui/models/library_search_results.dart` | Results model |
| `lib/ui/widgets/search/global_search_field.dart` | Sidebar input field |
| `lib/ui/widgets/search/search_result_tile.dart` | Result row |
| `lib/ui/screens/search_screen.dart` | Results screen and navigation |
| `lib/di/providers.dart` | `searchQueryProvider`, `debouncedSearchQueryProvider`, `librarySearchResultsProvider` |

## Providers

| Provider | Purpose |
|----------|---------|
| `searchQueryProvider` | Current query text (immediate) |
| `debouncedSearchQueryProvider` | Query after 200 ms debounce |
| `librarySearchResultsProvider` | Results for debounced query |

After library rescan, results refresh via `libraryRefreshProvider`.

## Limitations

- FTS5 and ranking not implemented — in-memory filtering is sufficient for a local library.
- Search hotkey not added.
- No separate "Search" nav item.
