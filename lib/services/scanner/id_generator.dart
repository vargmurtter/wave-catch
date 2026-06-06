import 'dart:convert';

import 'package:crypto/crypto.dart';

String normalizeKey(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

String hashId(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

String artistIdFor(String name) => hashId(normalizeKey(name));

String albumIdFor(String artistName, String albumName) =>
    hashId('${normalizeKey(artistName)}|${normalizeKey(albumName)}');

String trackIdFor(String filePath) => hashId(filePath);
