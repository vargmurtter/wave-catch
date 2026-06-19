// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wave Catch';

  @override
  String get navHome => 'Home';

  @override
  String get navArtists => 'Artists';

  @override
  String get navAlbums => 'Albums';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get later => 'Later';

  @override
  String get back => 'Back';

  @override
  String get recommended => 'Recommended';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String get edit => 'Edit';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get volume => 'Volume';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change this later in Settings.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeDescription =>
      'Choose your music folder. The app will scan it and create an index in .wave_catcher/library.db.';

  @override
  String get pickMusicFolder => 'Choose music folder';

  @override
  String get folderPickerHint =>
      'Open the folder picker dialog…\nIf you don\'t see it, check for windows behind the app.';

  @override
  String get scanning => 'Scanning…';

  @override
  String get scanFailed => 'Failed to scan the library';

  @override
  String folderPickerFailed(String error) {
    return 'Failed to open the folder picker: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get musicFolder => 'Music folder';

  @override
  String get notSelected => 'Not selected';

  @override
  String get changeFolder => 'Change folder';

  @override
  String get rescan => 'Rescan';

  @override
  String get albumGrouping => 'Album grouping';

  @override
  String get metadataEditing => 'Metadata editing';

  @override
  String get changeMusicFolderTitle => 'Change music folder?';

  @override
  String get changeMusicFolderBody =>
      'The current index will remain in the previous folder. A new .wave_catcher/library.db will be created for the new folder and scanned.';

  @override
  String get changeGroupingTitle => 'Change album grouping?';

  @override
  String get changeGroupingBody =>
      'This will change how albums are grouped in your library. Rescan now?';

  @override
  String get rescanNow => 'Rescan';

  @override
  String scanComplete(int trackCount, int albumCount, int artistCount) {
    return 'Done: $trackCount tracks, $albumCount albums, $artistCount artists';
  }

  @override
  String get scanError => 'Scan error';

  @override
  String get artistNotFound => 'Artist not found';

  @override
  String get albumNotFound => 'Album not found';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get tracks => 'Tracks';

  @override
  String get playlists => 'Playlists';

  @override
  String get search => 'Search';

  @override
  String get searchResults => 'Search results';

  @override
  String get searching => 'Searching…';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get popularTracks => 'Popular tracks';

  @override
  String get showAll => 'Show all';

  @override
  String get loadingInfo => 'Loading info…';

  @override
  String get allTracks => 'All tracks';

  @override
  String get otherAlbums => 'Other albums';

  @override
  String get trackAbout => 'About track';

  @override
  String get metadata => 'Metadata';

  @override
  String get year => 'Year';

  @override
  String get genre => 'Genre';

  @override
  String get format => 'Format';

  @override
  String get bitrate => 'Bitrate';

  @override
  String bitrateValue(int value) {
    return '$value kbps';
  }

  @override
  String get duration => 'Duration';

  @override
  String get trackNumber => 'Track number';

  @override
  String get discNumber => 'Disc number';

  @override
  String get currentPlaylist => 'Current playlist';

  @override
  String get selectTrack => 'Select a track';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get previousTrack => 'Previous track';

  @override
  String get nextTrack => 'Next track';

  @override
  String get repeat => 'Repeat';

  @override
  String get emptyLibrary =>
      'Library is empty. Add music to the selected folder and tap Rescan in Settings.';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String get recentlyAdded => 'Recently added';

  @override
  String get favoriteAlbums => 'Favorite albums';

  @override
  String get favoriteArtists => 'Favorite artists';

  @override
  String get playAll => 'Play all';

  @override
  String get albumsNotFound =>
      'No albums found. Check the music folder in Settings.';

  @override
  String get artistsNotFound =>
      'No artists found. Check the music folder in Settings.';

  @override
  String playlistsTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String get groupingByAlbumArtist => 'By tags (Album Artist)';

  @override
  String get groupingByAlbumArtistDesc =>
      'Albums are defined by the album artist tag and album title. Tracks with featured artists (feat.) stay in one album when Album Artist is set in the files.';

  @override
  String get groupingByFolder => 'By folder on disk';

  @override
  String get groupingByFolderDesc =>
      'Tracks in the same folder with the same album title are grouped together. Best when your music is neatly organized in folders.';

  @override
  String get groupingByAlbumTitle => 'By album title';

  @override
  String get groupingByAlbumTitleDesc =>
      'All tracks with the same album title are merged into one album. Useful for compilations and libraries with inconsistent tags. Warning: may merge different releases with the same title.';

  @override
  String get metadataInFile => 'Write to track files';

  @override
  String get metadataInFileDesc =>
      'Changes are written directly to audio file tags. Featured artists are saved in the override config because standard tags don\'t support them.';

  @override
  String get metadataOverride => 'Override config';

  @override
  String metadataOverrideDesc(String appDataDir) {
    return 'Changes are saved in $appDataDir/metadata_overrides.json in the library folder. Original files are not modified.';
  }

  @override
  String get editMetadata => 'Edit metadata';

  @override
  String get metadataSaved => 'Metadata saved';

  @override
  String get changesSavedInFile => 'Changes are saved to the track file';

  @override
  String get changesSavedInOverride =>
      'Changes are saved to the override config';

  @override
  String get featuredArtistsOverrideHint =>
      'Featured artists are saved in the override config.';

  @override
  String get pickCover => 'Choose cover';

  @override
  String get featuredArtists => 'Featured artists';

  @override
  String get commaSeparated => 'Comma-separated';

  @override
  String get title => 'Title';

  @override
  String get artist => 'Artist';

  @override
  String get album => 'Album';

  @override
  String get pickMusicFolderDialog => 'Choose music folder';

  @override
  String get pickCoverDialog => 'Choose cover image';

  @override
  String get errorMusicLibraryNotSelected => 'Music folder is not selected';

  @override
  String get errorTrackNotFound => 'Track not found';

  @override
  String get errorTitleRequired => 'Enter a track title';

  @override
  String get errorArtistRequired => 'Enter an artist';

  @override
  String get errorAlbumRequired => 'Enter an album';

  @override
  String get errorCoverReadFailed => 'Failed to read cover image file';

  @override
  String errorFileWriteFailed(String error) {
    return 'Failed to write tags to file: $error';
  }

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get variousArtists => 'Various artists';

  @override
  String get navExplore => 'Explore';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'Search YouTube Music…';

  @override
  String get exploreRecommendations => 'Recommended for you';

  @override
  String get exploreSimilar => 'Similar tracks';

  @override
  String get exploreSearchResults => 'Search results';

  @override
  String get explorePreview => 'Preview';

  @override
  String get exploreSaveToLibrary => 'Save to library';

  @override
  String get exploreInLibrary => 'In library';

  @override
  String get exploreSaving => 'Saving…';

  @override
  String get exploreSaveFailed => 'Failed to save track';

  @override
  String get exploreYtdlpMissing =>
      'yt-dlp is required for preview and saving tracks. Reinstall the app or install yt-dlp system-wide: brew install yt-dlp';

  @override
  String get exploreLibraryEmptyHint =>
      'Add music to your library to get personalized recommendations.';

  @override
  String get exploreNoResults => 'No tracks found';

  @override
  String get exploreOffline => 'Network is unavailable';

  @override
  String get settingsYtdlpStatus => 'yt-dlp';

  @override
  String settingsYtdlpAvailable(String version) {
    return 'Available ($version)';
  }

  @override
  String get settingsYtdlpMissing => 'Not found';

  @override
  String get settingsYtdlpCookiesTitle => 'YouTube authentication';

  @override
  String get settingsYtdlpCookiesHint =>
      'Required for age-restricted videos. Sign in to YouTube in your browser and confirm your age. Cookies contain sensitive data.';

  @override
  String get settingsYtdlpCookiesNone => 'No cookies';

  @override
  String get settingsYtdlpCookiesFile => 'From file';

  @override
  String get settingsYtdlpCookiesBrowser => 'From browser';

  @override
  String get settingsYtdlpCookiesFilePath => 'Cookies file';

  @override
  String get settingsYtdlpCookiesPickFile => 'Choose cookies.txt';

  @override
  String get settingsYtdlpCookiesBrowserLabel => 'Browser';

  @override
  String get exploreSaveAgeRestricted =>
      'This track is age-restricted. Configure YouTube cookies in Settings → yt-dlp.';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get deletePlaylist => 'Delete playlist';

  @override
  String get favorites => 'Favorites';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get removedFromPlaylist => 'Removed from playlist';

  @override
  String get playlistEmpty => 'This playlist is empty';

  @override
  String confirmDeletePlaylist(String name) {
    return 'Delete playlist \"$name\"?';
  }

  @override
  String get playlistNotFound => 'Playlist not found';

  @override
  String get playlistNameRequired => 'Enter a playlist name';

  @override
  String get inPlaylist => 'In playlist';
}
