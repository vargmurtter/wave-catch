import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/ui/theme/app_colors.dart';

class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    required this.size,
    this.borderRadius = 4,
    this.circular = false,
    this.seed,
  });

  final double size;
  final double borderRadius;
  final bool circular;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final hue = (seed?.hashCode ?? 0).abs() % 360;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: circular
            ? null
            : BorderRadius.circular(borderRadius),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.35).toColor(),
            HSLColor.fromAHSL(1, (hue + 40).toDouble() % 360, 0.6, 0.25)
                .toColor(),
          ],
        ),
      ),
      child: Icon(
        LucideIcons.music,
        color: AppColors.textPrimary.withValues(alpha: 0.6),
        size: size * 0.35,
      ),
    );
  }
}
