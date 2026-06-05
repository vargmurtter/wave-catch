import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/ui/models/nav_item.dart';
import 'package:music_player/ui/screens/albums_screen.dart';
import 'package:music_player/ui/screens/artists_screen.dart';
import 'package:music_player/ui/screens/home_screen.dart';
import 'package:music_player/ui/screens/playlists_screen.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/player/player_bar.dart';
import 'package:music_player/ui/widgets/player/queue_panel.dart';
import 'package:music_player/ui/widgets/sidebar/app_sidebar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNav = ref.watch(selectedNavItemProvider);
    final isQueueOpen = ref.watch(
      playerUiStateProvider.select((state) => state.isQueueOpen),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ContentArea(selectedNav: selectedNav),
                      ),
                      if (isQueueOpen) const QueuePanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PlayerBar(),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selectedNav});

  final NavItem selectedNav;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedNav.index,
      children: const [
        HomeScreen(),
        ArtistsScreen(),
        AlbumsScreen(),
        PlaylistsScreen(),
      ],
    );
  }
}
