import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/ui/mock/mock_data.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = MockData.playlists;

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: ScreenHeader(title: 'Плейлисты'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _PlaylistTile(
                  name: playlist.name,
                  trackCount: playlist.trackCount,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatefulWidget {
  const _PlaylistTile({
    required this.name,
    required this.trackCount,
  });

  final String name;
  final int trackCount;

  @override
  State<_PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<_PlaylistTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.surfaceElevated.withValues(alpha: 0.65)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                LucideIcons.listMusic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.trackCount} треков',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
