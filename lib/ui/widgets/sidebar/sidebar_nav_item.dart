import 'package:flutter/material.dart';

import 'package:music_player/ui/theme/app_colors.dart';

class SidebarNavItem extends StatefulWidget {
  const SidebarNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected
        ? AppColors.surfaceElevated.withValues(alpha: 0.65)
        : _isHovered
            ? AppColors.hover
            : Colors.transparent;

    final foregroundColor =
        widget.isSelected ? AppColors.textPrimary : AppColors.textSecondary;

    final iconColor =
        widget.isSelected ? AppColors.accent : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
