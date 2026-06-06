import 'dart:io';

import 'package:flutter/material.dart';

import 'package:music_player/ui/theme/app_colors.dart';

class ArtistHeroBanner extends StatelessWidget {
  const ArtistHeroBanner({
    super.key,
    required this.imagePath,
    this.height = 220,
  });

  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    if (!file.existsSync()) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                  AppColors.background.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
