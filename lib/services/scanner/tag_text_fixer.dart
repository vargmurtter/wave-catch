import 'dart:convert';

import 'package:windows1251/windows1251.dart';

/// Fixes CP1251 tags misread as Latin-1 (e.g. «Ôèëüòðóþùèé» → «Фильтрующий»).
class TagTextFixer {
  const TagTextFixer();

  String? fix(String? value) {
    if (value == null || value.isEmpty) return value;
    if (_isAsciiOnly(value) || _hasCyrillic(value)) return value;

    try {
      final bytes = latin1.encode(value);
      final candidate = windows1251.decode(bytes);
      if (_shouldAccept(candidate)) return candidate;
    } catch (_) {}

    return value;
  }

  bool _isAsciiOnly(String value) {
    for (final codeUnit in value.codeUnits) {
      if (codeUnit > 0x7F) return false;
    }
    return true;
  }

  bool _hasCyrillic(String value) {
    for (final rune in value.runes) {
      if (rune >= 0x0400 && rune <= 0x04FF) return true;
    }
    return false;
  }

  bool _shouldAccept(String candidate) {
    var cyrillicCount = 0;
    var letterCount = 0;

    for (final rune in candidate.runes) {
      if (_isLetter(rune)) {
        letterCount++;
        if (rune >= 0x0400 && rune <= 0x04FF) cyrillicCount++;
      }
    }

    if (cyrillicCount < 2) return false;
    if (letterCount == 0) return false;
    return cyrillicCount / letterCount >= 0.3;
  }

  static final _letterPattern = RegExp(r'\p{L}', unicode: true);

  bool _isLetter(int rune) =>
      _letterPattern.hasMatch(String.fromCharCode(rune));
}
