# Metadata editing

Users can edit track metadata from the track info panel (pencil button).

## Save modes

Configured in **Settings → Metadata editing**.

| Mode | Where changes are written |
|------|---------------------------|
| **Write to track files** | Audio file tags via `metadata_god` |
| **Override config** | `{musicRoot}/.wave_catcher/metadata_overrides.json` |

### Override config

File lives in the library folder and moves with the music.

```json
{
  "version": 1,
  "tracks": {
    "<trackId>": {
      "title": "Title",
      "artist": "Artist",
      "featuredArtists": ["Guest 1", "Guest 2"],
      "albumArtist": "Album Artist",
      "album": "Album",
      "year": 2020,
      "genre": "Rock",
      "trackNumber": 3,
      "discNumber": 1,
      "coverPath": ".wave_catcher/covers/<trackId>_custom.jpg",
      "updatedAtMs": 1710000000000
    }
  }
}
```

Key is SHA-256 hash of file path (`trackIdFor(filePath)`).

## Editable fields

- Track title
- Artist
- Featured artists
- Album Artist
- Album
- Year
- Genre
- Track number / disc number
- Cover art (jpg, jpeg, png, webp)

## Behavior on rescan

- **Override mode:** override entries are applied on top of file tags during scanning.
- **Write-to-file mode:** tags are read from files; only featured artists are pulled from override (standard tags do not support them).

After editing, the index in `library.db` updates immediately, without a full rescan.

## Limitations

- Read-only files cannot be changed in "Write to track files" mode — switch to override.
- Featured artists in write-to-file mode are saved in override config, not in tags.
- WAV and other formats with limited tag support may not support writing — use override.

## Architecture

```
TrackInfoPanel → MetadataEditService
  → MetadataFileWriter (inFile)
  → MetadataOverrideRepository (override)
  → LibraryRepository (incremental DB update)
```

During scanning: `MetadataOverrideApplier` applies overrides after `MetadataExtractor`.
