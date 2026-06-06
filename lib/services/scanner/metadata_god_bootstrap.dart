import 'package:metadata_god/metadata_god.dart';

bool _metadataGodInitialized = false;

/// Initializes metadata_god native bindings. Must run after macOS pods are installed.
void ensureMetadataGodInitialized() {
  if (_metadataGodInitialized) return;

  MetadataGod.initialize();
  _metadataGodInitialized = true;
}
