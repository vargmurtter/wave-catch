import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/services/scanner/scan_rules.dart';
import 'package:music_player/ui/models/playlist.dart';
import 'package:music_player/ui/theme/app_colors.dart';

String playlistDisplayName(AppLocalizations l10n, Playlist playlist) {
  if (playlist.id == kFavoritesPlaylistId) {
    return l10n.favorites;
  }
  if (playlist.id == kSavedFromExplorePlaylistId) {
    return l10n.savedFromExplore;
  }
  return playlist.name;
}

Future<Playlist?> showCreatePlaylistDialog(
  BuildContext context, {
  String? initialName,
}) {
  return showDialog<Playlist>(
    context: context,
    builder: (context) => CreatePlaylistDialog(initialName: initialName),
  );
}

class CreatePlaylistDialog extends ConsumerStatefulWidget {
  const CreatePlaylistDialog({super.key, this.initialName});

  final String? initialName;

  @override
  ConsumerState<CreatePlaylistDialog> createState() =>
      _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends ConsumerState<CreatePlaylistDialog> {
  late final TextEditingController _nameController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = AppLocalizations.of(context).playlistNameRequired;
      });
      return;
    }
    final playlist =
        ref.read(playlistActionsProvider).createPlaylist(name);
    Navigator.pop(context, playlist);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.createPlaylist),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.playlistName,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            l10n.save,
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
