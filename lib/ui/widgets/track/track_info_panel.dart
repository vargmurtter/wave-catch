import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';
import 'package:music_player/ui/widgets/common/frosted_panel.dart';

class TrackInfoPanel extends ConsumerWidget {
  const TrackInfoPanel({super.key});

  static const _width = 350.0;
  static const _playerBarHeight = 96.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(trackInfoPanelProvider);
    if (track == null) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 0,
      bottom: _playerBarHeight,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        child: FrostedPanel(
          color: AppColors.surfaceOverlay,
          blurSigma: 20,
          border: const Border(
            left: BorderSide(color: AppColors.divider, width: 0.5),
          ),
          child: SizedBox(
            width: _width,
            child: _TrackInfoContent(track: track),
          ),
        ),
      ),
    );
  }
}

class _TrackInfoContent extends ConsumerWidget {
  const _TrackInfoContent({required this.track});

  final Track track;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'О треке',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(trackInfoPanelProvider.notifier).close(),
                icon: const Icon(LucideIcons.x),
                color: AppColors.textSecondary,
                tooltip: 'Закрыть',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CoverArt(
                    size: 200,
                    seed: track.id,
                    imagePath: track.albumArtUrl,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  track.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (track.album != null)
                  _LinkRow(
                    label: 'Альбом',
                    value: track.album!,
                    onTap: () => ref
                        .read(libraryRouteProvider.notifier)
                        .openAlbum(track.albumId),
                  ),
                const SizedBox(height: 8),
                _LinkRow(
                  label: 'Исполнитель',
                  value: track.artist,
                  onTap: () => ref
                      .read(libraryRouteProvider.notifier)
                      .openArtist(track.artistId),
                ),
                if (track.year != null) ...[
                  const SizedBox(height: 8),
                  _MetaRow(label: 'Год', value: '${track.year}'),
                ],
                const SizedBox(height: 24),
                Text(
                  'Метаданные',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 12),
                _MetaRow(
                  label: 'Длительность',
                  value: _formatDuration(track.duration),
                ),
                if (track.trackNumber != null)
                  _MetaRow(
                    label: 'Номер трека',
                    value: '${track.trackNumber}',
                  ),
                if (track.genre != null)
                  _MetaRow(label: 'Жанр', value: track.genre!),
                if (track.format != null)
                  _MetaRow(label: 'Формат', value: track.format!),
                if (track.bitrate != null)
                  _MetaRow(label: 'Битрейт', value: '${track.bitrate} kbps'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatefulWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Text(
                widget.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? AppColors.accent : AppColors.textPrimary,
                  decoration: _isHovered ? TextDecoration.underline : null,
                  decorationColor: AppColors.accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
