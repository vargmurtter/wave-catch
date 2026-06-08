enum MetadataEditMode {
  inFile,
  override,
}

extension MetadataEditModeLabels on MetadataEditMode {
  String toJson() => name;

  static MetadataEditMode fromJson(String? value) {
    return MetadataEditMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => MetadataEditMode.override,
    );
  }
}
