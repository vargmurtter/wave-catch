import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:music_player/di/providers.dart';
import 'package:music_player/l10n/app_localizations.dart';
import 'package:music_player/ui/models/explore_track.dart';
import 'package:music_player/ui/theme/app_colors.dart';
import 'package:music_player/ui/widgets/explore/explore_track_card.dart';
import 'package:music_player/ui/widgets/explore/explore_track_tile.dart';
import 'package:music_player/ui/widgets/home/content_section.dart';
import 'package:music_player/ui/widgets/home/horizontal_card_list.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ytdlpAvailability = ref.watch(ytdlpAvailableProvider);
    final recommendations = ref.watch(exploreRecommendationsProvider);
    final query = _searchController.text.trim();
    final searchResults = query.isEmpty
        ? const AsyncValue<List<ExploreTrack>>.data([])
        : ref.watch(exploreSearchProvider(query));
    final suggestions = query.isEmpty
        ? const AsyncValue<ExploreSuggestionsState>.data(
            ExploreSuggestionsState(),
          )
        : ref.watch(exploreSuggestionsProvider(query));

    return ScreenScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            child: Text(
              l10n.exploreTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ytdlpAvailability.when(
            data: (available) {
              if (available) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _InfoBanner(
                  icon: LucideIcons.circleAlert,
                  message: l10n.exploreYtdlpMissing,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _InfoBanner(
                icon: LucideIcons.circleAlert,
                message: l10n.exploreYtdlpMissing,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.exploreSearchHint,
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(LucideIcons.x, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (query.isNotEmpty)
            suggestions.when(
              data: (state) {
                if (state.textSuggestions.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.textSuggestions
                        .map(
                          (text) => ActionChip(
                            label: Text(text),
                            onPressed: () {
                              _searchController.text = text;
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          if (query.isEmpty) ...[
            recommendations.when(
              data: (data) {
                if (data.libraryEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _InfoBanner(
                      icon: LucideIcons.info,
                      message: l10n.exploreLibraryEmptyHint,
                    ),
                  );
                }
                if (data.noExploreImports) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _InfoBanner(
                      icon: LucideIcons.info,
                      message: l10n.exploreNoImportsHint,
                    ),
                  );
                }
                if (data.youMightLike.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ContentSection(
                  title: l10n.exploreYouMightLike,
                  fullBleedChild: true,
                  child: HorizontalCardList(
                    itemCount: data.youMightLike.length,
                    itemBuilder: (context, index) {
                      return ExploreTrackCard(track: data.youMightLike[index]);
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ] else
            searchResults.when(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.exploreNoResults,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                      child: Text(
                        l10n.exploreSearchResults,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ...tracks.map((track) => ExploreTrackTile(track: track)),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.exploreOffline,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
