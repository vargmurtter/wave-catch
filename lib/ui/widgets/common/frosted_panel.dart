import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    required this.color,
    this.blurSigma = 16,
    this.border,
  });

  final Widget child;
  final Color color;
  final double blurSigma;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
