import 'dart:convert';

class TrackMetadataOverride {
  const TrackMetadataOverride({
    this.title,
    this.artist,
    this.featuredArtists,
    this.albumArtist,
    this.album,
    this.year,
    this.genre,
    this.trackNumber,
    this.discNumber,
    this.coverPath,
    this.updatedAtMs,
  });

  final String? title;
  final String? artist;
  final List<String>? featuredArtists;
  final String? albumArtist;
  final String? album;
  final int? year;
  final String? genre;
  final int? trackNumber;
  final int? discNumber;
  final String? coverPath;
  final int? updatedAtMs;

  bool get isEmpty =>
      title == null &&
      artist == null &&
      featuredArtists == null &&
      albumArtist == null &&
      album == null &&
      year == null &&
      genre == null &&
      trackNumber == null &&
      discNumber == null &&
      coverPath == null;

  TrackMetadataOverride copyWith({
    String? title,
    String? artist,
    List<String>? featuredArtists,
    String? albumArtist,
    String? album,
    int? year,
    String? genre,
    int? trackNumber,
    int? discNumber,
    String? coverPath,
    int? updatedAtMs,
  }) {
    return TrackMetadataOverride(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      featuredArtists: featuredArtists ?? this.featuredArtists,
      albumArtist: albumArtist ?? this.albumArtist,
      album: album ?? this.album,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      coverPath: coverPath ?? this.coverPath,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (featuredArtists != null) 'featuredArtists': featuredArtists,
      if (albumArtist != null) 'albumArtist': albumArtist,
      if (album != null) 'album': album,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (trackNumber != null) 'trackNumber': trackNumber,
      if (discNumber != null) 'discNumber': discNumber,
      if (coverPath != null) 'coverPath': coverPath,
      if (updatedAtMs != null) 'updatedAtMs': updatedAtMs,
    };
  }

  factory TrackMetadataOverride.fromJson(Map<String, dynamic> json) {
    final featuredRaw = json['featuredArtists'];
    List<String>? featuredArtists;
    if (featuredRaw is List) {
      featuredArtists = featuredRaw.whereType<String>().toList();
    }

    return TrackMetadataOverride(
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      featuredArtists: featuredArtists,
      albumArtist: json['albumArtist'] as String?,
      album: json['album'] as String?,
      year: json['year'] as int?,
      genre: json['genre'] as String?,
      trackNumber: json['trackNumber'] as int?,
      discNumber: json['discNumber'] as int?,
      coverPath: json['coverPath'] as String?,
      updatedAtMs: json['updatedAtMs'] as int?,
    );
  }
}

class MetadataOverridesFile {
  const MetadataOverridesFile({
    required this.version,
    required this.tracks,
  });

  final int version;
  final Map<String, TrackMetadataOverride> tracks;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'tracks': tracks.map((id, override) => MapEntry(id, override.toJson())),
    };
  }

  factory MetadataOverridesFile.fromJson(Map<String, dynamic> json) {
    final tracksRaw = json['tracks'];
    final tracks = <String, TrackMetadataOverride>{};
    if (tracksRaw is Map) {
      for (final entry in tracksRaw.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          tracks[entry.key.toString()] = TrackMetadataOverride.fromJson(value);
        }
      }
    }

    return MetadataOverridesFile(
      version: json['version'] as int? ?? 1,
      tracks: tracks,
    );
  }

  static MetadataOverridesFile empty() {
    return const MetadataOverridesFile(version: 1, tracks: {});
  }
}

List<String> parseFeaturedArtistsInput(String input) {
  return input
      .split(RegExp(r'[,;]'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

String formatFeaturedArtists(List<String> artists) {
  return artists.join(', ');
}

String encodeFeaturedArtists(List<String> artists) {
  return jsonEncode(artists);
}

List<String> decodeFeaturedArtists(String? json) {
  if (json == null || json.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.whereType<String>().toList();
    }
  } catch (_) {}
  return const [];
}
