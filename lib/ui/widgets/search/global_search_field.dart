import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/theme/app_colors.dart';

class GlobalSearchField extends ConsumerStatefulWidget {
  const GlobalSearchField({super.key});

  @override
  ConsumerState<GlobalSearchField> createState() => _GlobalSearchFieldState();
}

class _GlobalSearchFieldState extends ConsumerState<GlobalSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(searchQueryProvider, (previous, next) {
      if (next.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).set(value),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.search,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.surfaceElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                  icon: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: l10n.clear,
                )
              : null,
        ),
      ),
    );
  }
}
