import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/l10n/l10n_extensions.dart';
import 'package:music_player/services/metadata/metadata_edit_mode.dart';
import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/metadata/track_metadata_override.dart';
import 'package:music_player/services/scanner/scan_rules.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';

Future<void> showTrackMetadataEditDialog(
  BuildContext context,
  WidgetRef ref,
  Track track,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => TrackMetadataEditDialog(track: track),
  );
}

class TrackMetadataEditDialog extends ConsumerStatefulWidget {
  const TrackMetadataEditDialog({super.key, required this.track});

  final Track track;

  @override
  ConsumerState<TrackMetadataEditDialog> createState() =>
      _TrackMetadataEditDialogState();
}

class _TrackMetadataEditDialogState
    extends ConsumerState<TrackMetadataEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _featuredController;
  late final TextEditingController _albumArtistController;
  late final TextEditingController _albumController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _trackNumberController;
  late final TextEditingController _discNumberController;

  String? _coverPreviewPath;
  String? _newCoverImagePath;

  @override
  void initState() {
    super.initState();
    final track = widget.track;
    _titleController = TextEditingController(text: track.title);
    _artistController = TextEditingController(text: track.artist);
    _featuredController = TextEditingController(
      text: formatFeaturedArtists(track.featuredArtists),
    );
    _albumArtistController = TextEditingController(text: track.albumArtist ?? '');
    _albumController = TextEditingController(text: track.album ?? '');
    _yearController = TextEditingController(text: track.year?.toString() ?? '');
    _genreController = TextEditingController(text: track.genre ?? '');
    _trackNumberController = TextEditingController(
      text: track.trackNumber?.toString() ?? '',
    );
    _discNumberController = TextEditingController(
      text: track.discNumber?.toString() ?? '',
    );
    _coverPreviewPath = track.albumArtUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _featuredController.dispose();
    _albumArtistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _trackNumberController.dispose();
    _discNumberController.dispose();
    super.dispose();
  }

  int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  Future<void> _pickCover() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: kCoverExtensions.toList(),
      dialogTitle: l10n.pickCoverDialog,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null || !mounted) return;

    setState(() {
      _newCoverImagePath = path;
      _coverPreviewPath = path;
    });
  }

  Future<void> _save() async {
    final changes = TrackMetadataEdit(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      featuredArtists: parseFeaturedArtistsInput(_featuredController.text),
      albumArtist: _albumArtistController.text.trim().isEmpty
          ? null
          : _albumArtistController.text.trim(),
      album: _albumController.text.trim(),
      year: _parseOptionalInt(_yearController.text),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      trackNumber: _parseOptionalInt(_trackNumberController.text),
      discNumber: _parseOptionalInt(_discNumberController.text),
      newCoverImagePath: _newCoverImagePath,
    );

    final updated = await ref.read(trackMetadataEditProvider.notifier).save(
          trackId: widget.track.id,
          changes: changes,
        );

    if (!mounted) return;

    if (updated != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).metadataSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editState = ref.watch(trackMetadataEditProvider);
    final settings = ref.watch(appSettingsStateProvider);
    final modeLabel = settings.metadataEditMode == MetadataEditMode.inFile
        ? l10n.changesSavedInFile
        : l10n.changesSavedInOverride;
    final errorMessage = editState.errorCode != null
        ? metadataEditErrorMessage(
            l10n,
            editState.errorCode!,
            details: editState.errorDetails,
          )
        : editState.errorDetails;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.editMetadata),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (settings.metadataEditMode == MetadataEditMode.inFile) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.featuredArtistsOverrideHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    CoverArt(
                      size: 120,
                      seed: widget.track.id,
                      imagePath: _coverPreviewPath,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: editState.isSaving ? null : _pickCover,
                      icon: const Icon(LucideIcons.image, size: 16),
                      label: Text(l10n.pickCover),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _Field(label: l10n.title, controller: _titleController),
              _Field(label: l10n.artist, controller: _artistController),
              _Field(
                label: l10n.featuredArtists,
                controller: _featuredController,
                hint: l10n.commaSeparated,
              ),
              _Field(
                label: 'Album Artist',
                controller: _albumArtistController,
              ),
              _Field(label: l10n.album, controller: _albumController),
              _Field(label: l10n.year, controller: _yearController),
              _Field(label: l10n.genre, controller: _genreController),
              _Field(
                label: l10n.trackNumber,
                controller: _trackNumberController,
              ),
              _Field(
                label: l10n.discNumber,
                controller: _discNumberController,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: const TextStyle(color: AppColors.accent),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: editState.isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: editState.isSaving ? null : _save,
          child: editState.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  l10n.save,
                  style: const TextStyle(color: AppColors.accent),
                ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}
