import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Catch'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get navArtists;

  /// No description provided for @navAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get navAlbums;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your music folder. The app will scan it and create an index in .wave_catcher/library.db.'**
  String get welcomeDescription;

  /// No description provided for @pickMusicFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose music folder'**
  String get pickMusicFolder;

  /// No description provided for @folderPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Open the folder picker dialog…\nIf you don\'t see it, check for windows behind the app.'**
  String get folderPickerHint;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get scanning;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan the library'**
  String get scanFailed;

  /// No description provided for @folderPickerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open the folder picker: {error}'**
  String folderPickerFailed(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @musicFolder.
  ///
  /// In en, this message translates to:
  /// **'Music folder'**
  String get musicFolder;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @changeFolder.
  ///
  /// In en, this message translates to:
  /// **'Change folder'**
  String get changeFolder;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @albumGrouping.
  ///
  /// In en, this message translates to:
  /// **'Album grouping'**
  String get albumGrouping;

  /// No description provided for @metadataEditing.
  ///
  /// In en, this message translates to:
  /// **'Metadata editing'**
  String get metadataEditing;

  /// No description provided for @changeMusicFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Change music folder?'**
  String get changeMusicFolderTitle;

  /// No description provided for @changeMusicFolderBody.
  ///
  /// In en, this message translates to:
  /// **'The current index will remain in the previous folder. A new .wave_catcher/library.db will be created for the new folder and scanned.'**
  String get changeMusicFolderBody;

  /// No description provided for @changeGroupingTitle.
  ///
  /// In en, this message translates to:
  /// **'Change album grouping?'**
  String get changeGroupingTitle;

  /// No description provided for @changeGroupingBody.
  ///
  /// In en, this message translates to:
  /// **'This will change how albums are grouped in your library. Rescan now?'**
  String get changeGroupingBody;

  /// No description provided for @rescanNow.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescanNow;

  /// No description provided for @scanComplete.
  ///
  /// In en, this message translates to:
  /// **'Done: {trackCount} tracks, {albumCount} albums, {artistCount} artists'**
  String scanComplete(int trackCount, int albumCount, int artistCount);

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan error'**
  String get scanError;

  /// No description provided for @artistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Artist not found'**
  String get artistNotFound;

  /// No description provided for @albumNotFound.
  ///
  /// In en, this message translates to:
  /// **'Album not found'**
  String get albumNotFound;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @popularTracks.
  ///
  /// In en, this message translates to:
  /// **'Popular tracks'**
  String get popularTracks;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @loadingInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading info…'**
  String get loadingInfo;

  /// No description provided for @allTracks.
  ///
  /// In en, this message translates to:
  /// **'All tracks'**
  String get allTracks;

  /// No description provided for @otherAlbums.
  ///
  /// In en, this message translates to:
  /// **'Other albums'**
  String get otherAlbums;

  /// No description provided for @trackAbout.
  ///
  /// In en, this message translates to:
  /// **'About track'**
  String get trackAbout;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @bitrateValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kbps'**
  String bitrateValue(int value);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @trackNumber.
  ///
  /// In en, this message translates to:
  /// **'Track number'**
  String get trackNumber;

  /// No description provided for @discNumber.
  ///
  /// In en, this message translates to:
  /// **'Disc number'**
  String get discNumber;

  /// No description provided for @currentPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Current playlist'**
  String get currentPlaylist;

  /// No description provided for @selectTrack.
  ///
  /// In en, this message translates to:
  /// **'Select a track'**
  String get selectTrack;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @previousTrack.
  ///
  /// In en, this message translates to:
  /// **'Previous track'**
  String get previousTrack;

  /// No description provided for @nextTrack.
  ///
  /// In en, this message translates to:
  /// **'Next track'**
  String get nextTrack;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @emptyLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library is empty. Add music to the selected folder and tap Rescan in Settings.'**
  String get emptyLibrary;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get recentlyPlayed;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get recentlyAdded;

  /// No description provided for @favoriteAlbums.
  ///
  /// In en, this message translates to:
  /// **'Favorite albums'**
  String get favoriteAlbums;

  /// No description provided for @favoriteArtists.
  ///
  /// In en, this message translates to:
  /// **'Favorite artists'**
  String get favoriteArtists;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @albumsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found. Check the music folder in Settings.'**
  String get albumsNotFound;

  /// No description provided for @artistsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No artists found. Check the music folder in Settings.'**
  String get artistsNotFound;

  /// No description provided for @playlistsTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String playlistsTrackCount(int count);

  /// No description provided for @groupingByAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'By tags (Album Artist)'**
  String get groupingByAlbumArtist;

  /// No description provided for @groupingByAlbumArtistDesc.
  ///
  /// In en, this message translates to:
  /// **'Albums are defined by the album artist tag and album title. Tracks with featured artists (feat.) stay in one album when Album Artist is set in the files.'**
  String get groupingByAlbumArtistDesc;

  /// No description provided for @groupingByFolder.
  ///
  /// In en, this message translates to:
  /// **'By folder on disk'**
  String get groupingByFolder;

  /// No description provided for @groupingByFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Tracks in the same folder with the same album title are grouped together. Best when your music is neatly organized in folders.'**
  String get groupingByFolderDesc;

  /// No description provided for @groupingByAlbumTitle.
  ///
  /// In en, this message translates to:
  /// **'By album title'**
  String get groupingByAlbumTitle;

  /// No description provided for @groupingByAlbumTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'All tracks with the same album title are merged into one album. Useful for compilations and libraries with inconsistent tags. Warning: may merge different releases with the same title.'**
  String get groupingByAlbumTitleDesc;

  /// No description provided for @metadataInFile.
  ///
  /// In en, this message translates to:
  /// **'Write to track files'**
  String get metadataInFile;

  /// No description provided for @metadataInFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Changes are written directly to audio file tags. Featured artists are saved in the override config because standard tags don\'t support them.'**
  String get metadataInFileDesc;

  /// No description provided for @metadataOverride.
  ///
  /// In en, this message translates to:
  /// **'Override config'**
  String get metadataOverride;

  /// No description provided for @metadataOverrideDesc.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved in {appDataDir}/metadata_overrides.json in the library folder. Original files are not modified.'**
  String metadataOverrideDesc(String appDataDir);

  /// No description provided for @editMetadata.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get editMetadata;

  /// No description provided for @metadataSaved.
  ///
  /// In en, this message translates to:
  /// **'Metadata saved'**
  String get metadataSaved;

  /// No description provided for @changesSavedInFile.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved to the track file'**
  String get changesSavedInFile;

  /// No description provided for @changesSavedInOverride.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved to the override config'**
  String get changesSavedInOverride;

  /// No description provided for @featuredArtistsOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Featured artists are saved in the override config.'**
  String get featuredArtistsOverrideHint;

  /// No description provided for @pickCover.
  ///
  /// In en, this message translates to:
  /// **'Choose cover'**
  String get pickCover;

  /// No description provided for @featuredArtists.
  ///
  /// In en, this message translates to:
  /// **'Featured artists'**
  String get featuredArtists;

  /// No description provided for @commaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated'**
  String get commaSeparated;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @pickMusicFolderDialog.
  ///
  /// In en, this message translates to:
  /// **'Choose music folder'**
  String get pickMusicFolderDialog;

  /// No description provided for @pickCoverDialog.
  ///
  /// In en, this message translates to:
  /// **'Choose cover image'**
  String get pickCoverDialog;

  /// No description provided for @errorMusicLibraryNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Music folder is not selected'**
  String get errorMusicLibraryNotSelected;

  /// No description provided for @errorTrackNotFound.
  ///
  /// In en, this message translates to:
  /// **'Track not found'**
  String get errorTrackNotFound;

  /// No description provided for @errorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a track title'**
  String get errorTitleRequired;

  /// No description provided for @errorArtistRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an artist'**
  String get errorArtistRequired;

  /// No description provided for @errorAlbumRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an album'**
  String get errorAlbumRequired;

  /// No description provided for @errorCoverReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read cover image file'**
  String get errorCoverReadFailed;

  /// No description provided for @errorFileWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write tags to file: {error}'**
  String errorFileWriteFailed(String error);

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @variousArtists.
  ///
  /// In en, this message translates to:
  /// **'Various artists'**
  String get variousArtists;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search YouTube Music…'**
  String get exploreSearchHint;

  /// No description provided for @exploreRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get exploreRecommendations;

  /// No description provided for @exploreSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar tracks'**
  String get exploreSimilar;

  /// No description provided for @exploreSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get exploreSearchResults;

  /// No description provided for @explorePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get explorePreview;

  /// No description provided for @exploreSaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get exploreSaveToLibrary;

  /// No description provided for @exploreInLibrary.
  ///
  /// In en, this message translates to:
  /// **'In library'**
  String get exploreInLibrary;

  /// No description provided for @exploreSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get exploreSaving;

  /// No description provided for @exploreSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save track'**
  String get exploreSaveFailed;

  /// No description provided for @exploreYtdlpMissing.
  ///
  /// In en, this message translates to:
  /// **'yt-dlp is required for streaming and saving. Install it with Homebrew (brew install yt-dlp) or run scripts/fetch_ytdlp.sh before building.'**
  String get exploreYtdlpMissing;

  /// No description provided for @exploreLibraryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add music to your library to get personalized recommendations.'**
  String get exploreLibraryEmptyHint;

  /// No description provided for @exploreNoResults.
  ///
  /// In en, this message translates to:
  /// **'No tracks found'**
  String get exploreNoResults;

  /// No description provided for @exploreOffline.
  ///
  /// In en, this message translates to:
  /// **'Network is unavailable'**
  String get exploreOffline;

  /// No description provided for @settingsYtdlpStatus.
  ///
  /// In en, this message translates to:
  /// **'yt-dlp'**
  String get settingsYtdlpStatus;

  /// No description provided for @settingsYtdlpAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available ({version})'**
  String settingsYtdlpAvailable(String version);

  /// No description provided for @settingsYtdlpMissing.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get settingsYtdlpMissing;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylist;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to playlist'**
  String get addedToPlaylist;

  /// No description provided for @removedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Removed from playlist'**
  String get removedFromPlaylist;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty'**
  String get playlistEmpty;

  /// No description provided for @confirmDeletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist \"{name}\"?'**
  String confirmDeletePlaylist(String name);

  /// No description provided for @playlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Playlist not found'**
  String get playlistNotFound;

  /// No description provided for @playlistNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a playlist name'**
  String get playlistNameRequired;

  /// No description provided for @inPlaylist.
  ///
  /// In en, this message translates to:
  /// **'In playlist'**
  String get inPlaylist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
