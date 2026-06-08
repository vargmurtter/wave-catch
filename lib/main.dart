import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

import 'package:music_player/app.dart';
import 'package:music_player/app_info.dart';
import 'package:music_player/di/providers.dart';

const _minimumWindowSize = Size(900, 640);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setTitle(kAppDisplayName);
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
