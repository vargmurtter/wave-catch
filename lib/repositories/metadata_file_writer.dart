import 'dart:io';
import 'dart:typed_data';

import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;

import 'package:music_player/services/metadata/track_metadata_edit.dart';
import 'package:music_player/services/scanner/metadata_god_bootstrap.dart';

class MetadataFileWriter {
  Future<Metadata> readTags(String filePath) async {
    ensureMetadataGodInitialized();
    return MetadataGod.readMetadata(file: filePath);
  }

  Future<void> writeMerged({
    required String filePath,
    required TrackMetadataEdit changes,
    List<int>? coverBytes,
    String? coverMimeType,
  }) async {
    ensureMetadataGodInitialized();
    final current = await readTags(filePath);
    final fileSize = File(filePath).lengthSync();

    Picture? picture = current.picture;
    if (coverBytes != null && coverBytes.isNotEmpty) {
      picture = Picture(
        mimeType: coverMimeType ?? 'image/jpeg',
        data: coverBytes is Uint8List
            ? coverBytes
            : Uint8List.fromList(coverBytes),
      );
    }

    final merged = Metadata(
      title: changes.title,
      durationMs: current.durationMs,
      artist: changes.artist,
      album: changes.album,
      albumArtist: changes.albumArtist ?? current.albumArtist,
      trackNumber: changes.trackNumber ?? current.trackNumber,
      trackTotal: current.trackTotal,
      discNumber: changes.discNumber ?? current.discNumber,
      discTotal: current.discTotal,
      year: changes.year ?? current.year,
      genre: changes.genre ?? current.genre,
      picture: picture,
      fileSize: fileSize,
    );

    try {
      await MetadataGod.writeMetadata(file: filePath, metadata: merged);
    } on Object catch (error) {
      throw MetadataEditException(
        'Не удалось записать теги в файл: $error',
      );
    }
  }

  Future<({List<int> bytes, String mimeType})?> readCoverBytes(
    String imagePath,
  ) async {
    final file = File(imagePath);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    final extension = p.extension(imagePath).replaceFirst('.', '').toLowerCase();
    final mimeType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    return (bytes: bytes, mimeType: mimeType);
  }
}
