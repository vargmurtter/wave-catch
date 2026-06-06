import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'package:music_player/app.dart';
import 'package:music_player/di/providers.dart';

const _minimumWindowSize = Size(900, 640);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(_minimumWindowSize);
  }

  final container = ProviderContainer();
  await container.read(settingsServiceProvider).load();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MainApp(),
    ),
  );
}
