import 'package:music_player/app_paths.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/scanner/album_grouping_strategy.dart';

extension AlbumGroupingStrategyL10n on AlbumGroupingStrategy {
  String labelL10n(AppLocalizations l10n) => switch (this) {
        AlbumGroupingStrategy.byAlbumArtist => l10n.groupingByAlbumArtist,
        AlbumGroupingStrategy.byFolder => l10n.groupingByFolder,
        AlbumGroupingStrategy.byAlbumTitle => l10n.groupingByAlbumTitle,
      };

  String descriptionL10n(AppLocalizations l10n) => switch (this) {
        AlbumGroupingStrategy.byAlbumArtist => l10n.groupingByAlbumArtistDesc,
        AlbumGroupingStrategy.byFolder => l10n.groupingByFolderDesc,
        AlbumGroupingStrategy.byAlbumTitle => l10n.groupingByAlbumTitleDesc,
      };
}

extension MetadataEditModeL10n on MetadataEditMode {
  String labelL10n(AppLocalizations l10n) => switch (this) {
        MetadataEditMode.inFile => l10n.metadataInFile,
        MetadataEditMode.override => l10n.metadataOverride,
      };

  String descriptionL10n(AppLocalizations l10n) => switch (this) {
        MetadataEditMode.inFile => l10n.metadataInFileDesc,
        MetadataEditMode.override =>
          l10n.metadataOverrideDesc(kAppDataDirName),
      };
}

String metadataEditErrorMessage(
  AppLocalizations l10n,
  MetadataEditErrorCode code, {
  String? details,
}) {
  return switch (code) {
    MetadataEditErrorCode.musicLibraryNotSelected =>
      l10n.errorMusicLibraryNotSelected,
    MetadataEditErrorCode.trackNotFound => l10n.errorTrackNotFound,
    MetadataEditErrorCode.titleRequired => l10n.errorTitleRequired,
    MetadataEditErrorCode.artistRequired => l10n.errorArtistRequired,
    MetadataEditErrorCode.albumRequired => l10n.errorAlbumRequired,
    MetadataEditErrorCode.coverReadFailed => l10n.errorCoverReadFailed,
    MetadataEditErrorCode.fileWriteFailed =>
      l10n.errorFileWriteFailed(details ?? ''),
  };
}
