import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_player/di/providers.dart';

void main() {
  group('libraryRefreshProvider', () {
    test('does not recreate LibraryService on refresh', () {
      final container = ProviderContainer();

      final serviceBefore = container.read(libraryServiceProvider);
      container.read(libraryRefreshProvider.notifier).refresh();
      final serviceAfter = container.read(libraryServiceProvider);

      expect(identical(serviceBefore, serviceAfter), isTrue);
      container.dispose();
    });

    test('does not recreate PlaylistService on refresh', () {
      final container = ProviderContainer();

      final serviceBefore = container.read(playlistServiceProvider);
      container.read(libraryRefreshProvider.notifier).refresh();
      final serviceAfter = container.read(playlistServiceProvider);

      expect(identical(serviceBefore, serviceAfter), isTrue);
      container.dispose();
    });

    test('still invalidates library read providers', () {
      final container = ProviderContainer();

      final revisionBefore = container.read(libraryRefreshProvider);
      container.read(libraryRefreshProvider.notifier).refresh();
      final revisionAfter = container.read(libraryRefreshProvider);

      expect(revisionAfter, revisionBefore + 1);
      container.dispose();
    });
  });
}
