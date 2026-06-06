import 'package:music_player/app_paths.dart';

enum MetadataEditMode {
  inFile,
  override,
}

extension MetadataEditModeLabels on MetadataEditMode {
  String get label => switch (this) {
        MetadataEditMode.inFile => 'Запись в файлы треков',
        MetadataEditMode.override => 'Override-конфиг',
      };

  String get description => switch (this) {
        MetadataEditMode.inFile =>
          'Изменения записываются непосредственно в теги аудиофайлов. '
          'Приглашённые исполнители сохраняются в override-конфиг, '
          'так как стандартные теги их не поддерживают.',
        MetadataEditMode.override =>
          'Изменения сохраняются в $kAppDataDirName/metadata_overrides.json '
          'в папке библиотеки. Исходные файлы не изменяются.',
      };

  String toJson() => name;

  static MetadataEditMode fromJson(String? value) {
    return MetadataEditMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => MetadataEditMode.override,
    );
  }
}
