enum YtdlpCookieSource {
  none,
  file,
  browser;

  static YtdlpCookieSource fromJson(String? value) {
    switch (value) {
      case 'file':
        return YtdlpCookieSource.file;
      case 'browser':
        return YtdlpCookieSource.browser;
      default:
        return YtdlpCookieSource.none;
    }
  }

  String toJson() => name;
}

const kYtdlpBrowsers = ['chrome', 'safari', 'firefox', 'brave', 'edge'];

class YtdlpAuthSettings {
  const YtdlpAuthSettings({
    this.source = YtdlpCookieSource.none,
    this.cookiesFilePath,
    this.browser = 'chrome',
  });

  final YtdlpCookieSource source;
  final String? cookiesFilePath;
  final String browser;

  YtdlpAuthSettings copyWith({
    YtdlpCookieSource? source,
    String? cookiesFilePath,
    String? browser,
  }) {
    return YtdlpAuthSettings(
      source: source ?? this.source,
      cookiesFilePath: cookiesFilePath ?? this.cookiesFilePath,
      browser: browser ?? this.browser,
    );
  }
}
