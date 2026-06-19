import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/repositories/ytdlp_binary_resolver.dart';

void main() {
  group('bundledYtdlpPath', () {
    test('macOS resolves path inside app bundle', () {
      const executable =
          '/Applications/Wave Catch.app/Contents/MacOS/Wave Catch';

      final path = bundledYtdlpPath(executable, isMacOS: true);

      expect(
        path,
        '/Applications/Wave Catch.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/bin/macos/yt-dlp',
      );
    });

    test('Linux resolves path next to executable', () {
      const executable = '/opt/wave_catch/bundle/wave_catch';

      final path = bundledYtdlpPath(executable, isLinux: true);

      expect(
        path,
        '/opt/wave_catch/bundle/data/flutter_assets/assets/bin/linux/yt-dlp',
      );
    });

    test('Windows resolves path next to executable', () {
      const executable = r'C:\Program Files\Wave Catch\wave_catch.exe';

      final path = bundledYtdlpPath(executable, isWindows: true);

      expect(
        path.replaceAll(r'\', '/'),
        endsWith('data/flutter_assets/assets/bin/windows/yt-dlp.exe'),
      );
    });
  });
}
