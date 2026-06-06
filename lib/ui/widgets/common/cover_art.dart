import 'dart:io';

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
    this.imagePath,
  });

  final double size;
  final double borderRadius;
  final bool circular;
  final String? seed;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final imageFile = _resolveImageFile(imagePath);
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: circular
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius),
        child: Image.file(
          imageFile,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PlaceholderCover(
            size: size,
            borderRadius: borderRadius,
            circular: circular,
            seed: seed,
          ),
        ),
      );
    }

    return _PlaceholderCover(
      size: size,
      borderRadius: borderRadius,
      circular: circular,
      seed: seed,
    );
  }

  File? _resolveImageFile(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({
    required this.size,
    required this.borderRadius,
    required this.circular,
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
