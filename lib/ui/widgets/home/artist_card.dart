import 'package:flutter/material.dart';

import 'package:music_player/ui/models/artist.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/cover_art.dart';

class ArtistCard extends StatefulWidget {
  const ArtistCard({
    super.key,
    required this.artist,
    this.enableHoverScale = true,
    this.onTap,
  });

  final Artist artist;
  final bool enableHoverScale;
  final VoidCallback? onTap;

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final coverSize = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 160.0;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _isHovered && widget.enableHoverScale
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: CoverArt(
                size: coverSize,
                circular: true,
                seed: widget.artist.id,
                imagePath: widget.artist.imageUrl,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.onTap,
            child: widget.enableHoverScale
                ? AnimatedScale(
                    scale: _isHovered ? 1.03 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: content,
                  )
                : content,
          ),
        );
      },
    );
  }
}
