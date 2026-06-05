import 'package:flutter/material.dart';

import 'package:music_player/ui/theme/app_colors.dart';

class ContentSection extends StatelessWidget {
  const ContentSection({
    super.key,
    required this.title,
    required this.child,
    this.fullBleedChild = false,
    this.horizontalPadding = 32,
  });

  final String title;
  final Widget child;
  final bool fullBleedChild;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        if (fullBleedChild)
          child
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
      ],
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.horizontalPadding = 32,
  });

  final String title;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class ScreenScrollView extends StatelessWidget {
  const ScreenScrollView({
    super.key,
    required this.child,
    this.bottomPadding = 32,
  });

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: child,
      ),
    );
  }
}

class ScreenBody extends StatelessWidget {
  const ScreenBody({
    super.key,
    required this.child,
    this.topPadding = 24,
    this.horizontalPadding = 32,
    this.bottomPadding = 32,
  });

  final Widget child;
  final double topPadding;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      child: child,
    );
  }
}

class PlaceholderGradient extends StatelessWidget {
  const PlaceholderGradient({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final hue = seed.hashCode.abs() % 360;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.35).toColor(),
            AppColors.surface,
          ],
        ),
      ),
    );
  }
}
