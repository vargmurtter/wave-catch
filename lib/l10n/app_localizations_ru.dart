// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Wave Catch';

  @override
  String get navHome => 'Главное';

  @override
  String get navArtists => 'Исполнители';

  @override
  String get navAlbums => 'Альбомы';

  @override
  String get navPlaylists => 'Плейлисты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get change => 'Изменить';

  @override
  String get later => 'Позже';

  @override
  String get back => 'Назад';

  @override
  String get recommended => 'Рекомендуется';

  @override
  String get close => 'Закрыть';

  @override
  String get clear => 'Очистить';

  @override
  String get edit => 'Редактировать';

  @override
  String get play => 'Воспроизвести';

  @override
  String get pause => 'Пауза';

  @override
  String get volume => 'Громкость';

  @override
  String get languageTitle => 'Выберите язык';

  @override
  String get languageSubtitle => 'Его можно изменить позже в настройках.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get welcomeTitle => 'Добро пожаловать';

  @override
  String get welcomeDescription =>
      'Выберите папку с музыкой. Приложение просканирует её и создаст индекс в .wave_catcher/library.db.';

  @override
  String get pickMusicFolder => 'Выбрать папку с музыкой';

  @override
  String get folderPickerHint =>
      'Откройте диалог выбора папки…\nЕсли его не видно, проверьте окна за приложением.';

  @override
  String get scanning => 'Сканирование…';

  @override
  String get scanFailed => 'Не удалось просканировать библиотеку';

  @override
  String folderPickerFailed(String error) {
    return 'Не удалось открыть диалог выбора папки: $error';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get musicFolder => 'Папка с музыкой';

  @override
  String get notSelected => 'Не выбрана';

  @override
  String get changeFolder => 'Изменить папку';

  @override
  String get rescan => 'Пересканировать';

  @override
  String get albumGrouping => 'Группировка альбомов';

  @override
  String get metadataEditing => 'Редактирование метаданных';

  @override
  String get changeMusicFolderTitle => 'Изменить папку с музыкой?';

  @override
  String get changeMusicFolderBody =>
      'Текущий индекс останется в прежней папке. Для новой папки будет создан .wave_catcher/library.db и выполнено сканирование.';

  @override
  String get changeGroupingTitle => 'Изменить группировку альбомов?';

  @override
  String get changeGroupingBody =>
      'Изменится состав альбомов в библиотеке. Пересканировать сейчас?';

  @override
  String get rescanNow => 'Пересканировать';

  @override
  String scanComplete(int trackCount, int albumCount, int artistCount) {
    return 'Готово: $trackCount треков, $albumCount альбомов, $artistCount исполнителей';
  }

  @override
  String get scanError => 'Ошибка сканирования';

  @override
  String get artistNotFound => 'Исполнитель не найден';

  @override
  String get albumNotFound => 'Альбом не найден';

  @override
  String get albums => 'Альбомы';

  @override
  String get artists => 'Исполнители';

  @override
  String get tracks => 'Треки';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get search => 'Поиск';

  @override
  String get searchResults => 'Результаты поиска';

  @override
  String get searching => 'Поиск…';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get popularTracks => 'Популярные треки';

  @override
  String get showAll => 'Показать все';

  @override
  String get loadingInfo => 'Загрузка информации…';

  @override
  String get allTracks => 'Все треки';

  @override
  String get otherAlbums => 'Другие альбомы';

  @override
  String get trackAbout => 'О треке';

  @override
  String get metadata => 'Метаданные';

  @override
  String get year => 'Год';

  @override
  String get genre => 'Жанр';

  @override
  String get format => 'Формат';

  @override
  String get bitrate => 'Битрейт';

  @override
  String bitrateValue(int value) {
    return '$value kbps';
  }

  @override
  String get duration => 'Длительность';

  @override
  String get trackNumber => 'Номер трека';

  @override
  String get discNumber => 'Номер диска';

  @override
  String get currentPlaylist => 'Текущий плейлист';

  @override
  String get selectTrack => 'Выберите трек';

  @override
  String get shuffle => 'Случайный порядок';

  @override
  String get previousTrack => 'Предыдущий трек';

  @override
  String get nextTrack => 'Следующий трек';

  @override
  String get repeat => 'Повтор';

  @override
  String get emptyLibrary =>
      'Библиотека пуста. Добавьте музыку в выбранную папку и нажмите «Пересканировать» в настройках.';

  @override
  String get recentlyPlayed => 'Последнее прослушанное';

  @override
  String get recentlyAdded => 'Последнее добавленное';

  @override
  String get favoriteAlbums => 'Любимые альбомы';

  @override
  String get favoriteArtists => 'Любимые исполнители';

  @override
  String get playAll => 'Играть всё';

  @override
  String get albumsNotFound =>
      'Альбомы не найдены. Проверьте папку с музыкой в настройках.';

  @override
  String get artistsNotFound =>
      'Исполнители не найдены. Проверьте папку с музыкой в настройках.';

  @override
  String playlistsTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
    );
    return '$_temp0';
  }

  @override
  String get groupingByAlbumArtist => 'По тегам (Album Artist)';

  @override
  String get groupingByAlbumArtistDesc =>
      'Альбом определяется исполнителем альбома из тегов файла и его названием. Треки с приглашёнными артистами (feat.) останутся в одном альбоме, если в файлах указан Album Artist.';

  @override
  String get groupingByFolder => 'По папке на диске';

  @override
  String get groupingByFolderDesc =>
      'Треки из одной папки с одинаковым названием альбома считаются одним альбомом. Подходит, если музыка аккуратно разложена по папкам на диске.';

  @override
  String get groupingByAlbumTitle => 'По названию альбома';

  @override
  String get groupingByAlbumTitleDesc =>
      'Все треки с одинаковым названием альбома объединяются в один. Удобно для сборников и библиотек с неоднородными тегами. Внимание: может объединить разные релизы с одинаковым названием.';

  @override
  String get metadataInFile => 'Запись в файлы треков';

  @override
  String get metadataInFileDesc =>
      'Изменения записываются непосредственно в теги аудиофайлов. Приглашённые исполнители сохраняются в override-конфиг, так как стандартные теги их не поддерживают.';

  @override
  String get metadataOverride => 'Override-конфиг';

  @override
  String metadataOverrideDesc(String appDataDir) {
    return 'Изменения сохраняются в $appDataDir/metadata_overrides.json в папке библиотеки. Исходные файлы не изменяются.';
  }

  @override
  String get editMetadata => 'Редактировать метаданные';

  @override
  String get metadataSaved => 'Метаданные сохранены';

  @override
  String get changesSavedInFile => 'Изменения сохраняются в файл трека';

  @override
  String get changesSavedInOverride =>
      'Изменения сохраняются в override-конфиг';

  @override
  String get featuredArtistsOverrideHint =>
      'Приглашённые исполнители сохраняются в override-конфиг.';

  @override
  String get pickCover => 'Выбрать обложку';

  @override
  String get featuredArtists => 'Приглашённые исполнители';

  @override
  String get commaSeparated => 'Через запятую';

  @override
  String get title => 'Название';

  @override
  String get artist => 'Исполнитель';

  @override
  String get album => 'Альбом';

  @override
  String get pickMusicFolderDialog => 'Выберите папку с музыкой';

  @override
  String get pickCoverDialog => 'Выберите обложку';

  @override
  String get errorMusicLibraryNotSelected => 'Папка с музыкой не выбрана';

  @override
  String get errorTrackNotFound => 'Трек не найден';

  @override
  String get errorTitleRequired => 'Укажите название трека';

  @override
  String get errorArtistRequired => 'Укажите исполнителя';

  @override
  String get errorAlbumRequired => 'Укажите альбом';

  @override
  String get errorCoverReadFailed => 'Не удалось прочитать файл обложки';

  @override
  String errorFileWriteFailed(String error) {
    return 'Не удалось записать теги в файл: $error';
  }

  @override
  String get unknownArtist => 'Неизвестный исполнитель';

  @override
  String get unknownAlbum => 'Неизвестный альбом';

  @override
  String get variousArtists => 'Разные исполнители';

  @override
  String get navExplore => 'Исследование';

  @override
  String get exploreTitle => 'Исследование';

  @override
  String get exploreSearchHint => 'Поиск в YouTube Music…';

  @override
  String get exploreRecommendations => 'Рекомендации';

  @override
  String get exploreSimilar => 'Похожие треки';

  @override
  String get exploreSearchResults => 'Результаты поиска';

  @override
  String get explorePreview => 'Превью';

  @override
  String get exploreSaveToLibrary => 'Сохранить в библиотеку';

  @override
  String get exploreInLibrary => 'В библиотеке';

  @override
  String get exploreSaving => 'Сохранение…';

  @override
  String get exploreSaveFailed => 'Не удалось сохранить трек';

  @override
  String get exploreYtdlpMissing =>
      'Для стриминга и сохранения нужен yt-dlp. Установите через Homebrew (brew install yt-dlp) или запустите scripts/fetch_ytdlp.sh перед сборкой.';

  @override
  String get exploreLibraryEmptyHint =>
      'Добавьте музыку в библиотеку, чтобы получать рекомендации.';

  @override
  String get exploreNoResults => 'Треки не найдены';

  @override
  String get exploreOffline => 'Нет подключения к сети';

  @override
  String get settingsYtdlpStatus => 'yt-dlp';

  @override
  String settingsYtdlpAvailable(String version) {
    return 'Доступен ($version)';
  }

  @override
  String get settingsYtdlpMissing => 'Не найден';

  @override
  String get settingsYtdlpCookiesTitle => 'Авторизация YouTube';

  @override
  String get settingsYtdlpCookiesHint =>
      'Нужна для видео с возрастным ограничением. Войдите в YouTube в браузере и подтвердите возраст. Cookies содержат чувствительные данные.';

  @override
  String get settingsYtdlpCookiesNone => 'Без cookies';

  @override
  String get settingsYtdlpCookiesFile => 'Из файла';

  @override
  String get settingsYtdlpCookiesBrowser => 'Из браузера';

  @override
  String get settingsYtdlpCookiesFilePath => 'Файл cookies';

  @override
  String get settingsYtdlpCookiesPickFile => 'Выбрать cookies.txt';

  @override
  String get settingsYtdlpCookiesBrowserLabel => 'Браузер';

  @override
  String get exploreSaveAgeRestricted =>
      'Трек с возрастным ограничением. Настройте cookies YouTube в Настройки → yt-dlp.';

  @override
  String get createPlaylist => 'Создать плейлист';

  @override
  String get playlistName => 'Название плейлиста';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get removeFromPlaylist => 'Удалить из плейлиста';

  @override
  String get deletePlaylist => 'Удалить плейлист';

  @override
  String get favorites => 'Избранное';

  @override
  String get addedToPlaylist => 'Добавлено в плейлист';

  @override
  String get removedFromPlaylist => 'Удалено из плейлиста';

  @override
  String get playlistEmpty => 'Плейлист пуст';

  @override
  String confirmDeletePlaylist(String name) {
    return 'Удалить плейлист «$name»?';
  }

  @override
  String get playlistNotFound => 'Плейлист не найден';

  @override
  String get playlistNameRequired => 'Введите название плейлиста';

  @override
  String get inPlaylist => 'В плейлисте';
}
