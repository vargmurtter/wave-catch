import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/common/frosted_panel.dart';
import 'package:music_player/ui/widgets/search/global_search_field.dart';
import 'package:music_player/ui/widgets/sidebar/sidebar_nav_item.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  static const _width = 240.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNavItemProvider);

    return FrostedPanel(
      color: AppColors.sidebarOverlay,
      blurSigma: 20,
      border: const Border(
        right: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.music2,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Music Player',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const GlobalSearchField(),
            SidebarNavItem(
              label: 'Главное',
              icon: LucideIcons.house,
              isSelected: selected == NavItem.main,
              onTap: () => ref
                  .read(selectedNavItemProvider.notifier)
                  .select(NavItem.main),
            ),
            SidebarNavItem(
              label: 'Исполнители',
              icon: LucideIcons.users,
              isSelected: selected == NavItem.artists,
              onTap: () => ref
                  .read(selectedNavItemProvider.notifier)
                  .select(NavItem.artists),
            ),
            SidebarNavItem(
              label: 'Альбомы',
              icon: LucideIcons.disc3,
              isSelected: selected == NavItem.albums,
              onTap: () => ref
                  .read(selectedNavItemProvider.notifier)
                  .select(NavItem.albums),
            ),
            SidebarNavItem(
              label: 'Плейлисты',
              icon: LucideIcons.listMusic,
              isSelected: selected == NavItem.playlists,
              onTap: () => ref
                  .read(selectedNavItemProvider.notifier)
                  .select(NavItem.playlists),
            ),
            const Spacer(),
            SidebarNavItem(
              label: 'Настройки',
              icon: LucideIcons.settings,
              isSelected: selected == NavItem.settings,
              onTap: () => ref
                  .read(selectedNavItemProvider.notifier)
                  .select(NavItem.settings),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
