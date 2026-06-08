import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/theme/app_colors.dart';

class PlayActionButton extends StatefulWidget {
  const PlayActionButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final String? tooltip;
  final bool enabled;

  @override
  State<PlayActionButton> createState() => _PlayActionButtonState();
}

class _PlayActionButtonState extends State<PlayActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onPressed != null;
    final tooltip = widget.tooltip ?? AppLocalizations.of(context).play;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: IconButton(
        onPressed: active ? widget.onPressed : null,
        tooltip: tooltip,
        icon: const Icon(LucideIcons.play, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: active
              ? (_isHovered
                  ? AppColors.accent.withValues(alpha: 0.85)
                  : AppColors.accent)
              : AppColors.surfaceElevated,
          foregroundColor: active
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          minimumSize: const Size(56, 56),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
