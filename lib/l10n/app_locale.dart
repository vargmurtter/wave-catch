import 'package:flutter/material.dart';

enum AppLanguage {
  en,
  ru;

  String get code => switch (this) {
        AppLanguage.en => 'en',
        AppLanguage.ru => 'ru',
      };

  Locale get locale => Locale(code);

  static AppLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return null;
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('ru'),
  ];
}
