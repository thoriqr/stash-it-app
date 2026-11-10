// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsBackToInbox => 'Kembali ke Inbox';

  @override
  String get settingsAppearance => 'TAMPILAN';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get settingsLanguage => 'BAHASA';

  @override
  String get languageSystemDefault => 'Bawaan sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navCollections => 'Koleksi';

  @override
  String get navSearch => 'Cari';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTooltip => 'Pengaturan';

  @override
  String get clearTooltip => 'Kosongkan';

  @override
  String get refreshTooltip => 'Muat ulang';

  @override
  String get dismissAction => 'Tutup';

  @override
  String get sessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk melanjutkan.';

  @override
  String get genericReadRateLimited =>
      'Terlalu banyak percobaan. Coba lagi sebentar lagi.';

  @override
  String get genericReadServerFault =>
      'Kami tidak dapat menghubungi server. Coba lagi sebentar lagi.';

  @override
  String get genericReadUnreadable =>
      'Kami tidak dapat membaca balasan server. Coba lagi.';

  @override
  String get retryAfterSecond => '1 detik';

  @override
  String retryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count detik',
      one: '1 detik',
    );
    return '$_temp0';
  }

  @override
  String retryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit',
      one: '1 menit',
    );
    return '$_temp0';
  }

  @override
  String retryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jam',
      one: '1 jam',
    );
    return '$_temp0';
  }

  @override
  String get themePreferenceNotSaved =>
      'Theme changed, but the preference could not be saved.';

  @override
  String get languagePreferenceNotSaved =>
      'Language changed, but the preference could not be saved.';

  @override
  String get savedTimeJustNow => 'Baru saja disimpan';

  @override
  String savedTimeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count menit lalu',
    );
    return '$_temp0';
  }

  @override
  String savedTimeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count jam lalu',
    );
    return '$_temp0';
  }

  @override
  String get savedTimeYesterday => 'Disimpan kemarin';

  @override
  String savedTimeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count hari lalu',
    );
    return '$_temp0';
  }

  @override
  String get profileIdentityEmailPassword => 'Email & kata sandi';

  @override
  String get profileIdentityUnknown => 'Tidak diketahui';

  @override
  String get pendingUrlsExpired =>
      'Beberapa tautan yang disimpan di perangkat ini kedaluwarsa setelah tujuh hari.';

  @override
  String pendingSummaryLocalList(int saved) {
    String _temp0 = intl.Intl.pluralLogic(
      saved,
      locale: localeName,
      other: '$saved tautan',
    );
    return 'Tersimpan $_temp0, tetapi perangkat ini tidak dapat memperbarui daftar. Periksa daftar sebelum mencoba lagi.';
  }

  @override
  String get pendingSummaryUncertainSingle =>
      'Kami tidak dapat mengonfirmasi penyimpanan. Tautan masih ada di perangkat ini. Periksa Inbox sebelum mencoba lagi.';

  @override
  String pendingSummaryUncertainNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Kami tidak dapat mengonfirmasi penyimpanan tautan ini.$_temp0 Periksa Inbox sebelum mencoba lagi.';
  }

  @override
  String pendingSummaryUncertainPartial(
    int saved,
    int total,
    int uncertain,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan. Kami tidak dapat mengonfirmasi $uncertain tautan.$_temp0 Periksa Inbox sebelum mencoba lagi.';
  }

  @override
  String pendingSummaryRateLimitedSingleNoneSavedNoWait(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tautan tidak tersimpan. Anda menyimpan terlalu cepat. Coba lagi sebentar lagi.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedSingleNoneSavedWithWait(
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tautan tidak tersimpan. Anda menyimpan terlalu cepat. Coba lagi dalam $wait.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedNoneSavedNoWait(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tidak ada tautan yang tersimpan. Anda menyimpan terlalu cepat. Coba lagi sebentar lagi.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedNoneSavedWithWait(
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tidak ada tautan yang tersimpan. Anda menyimpan terlalu cepat. Coba lagi dalam $wait.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedPartialNoWait(
    int saved,
    int total,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan. Anda menyimpan terlalu cepat. Coba lagi sebentar lagi.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedPartialWithWait(
    int saved,
    int total,
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan. Anda menyimpan terlalu cepat. Coba lagi dalam $wait.$_temp0';
  }

  @override
  String pendingSummaryAuthSingleNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tautan tidak tersimpan. Masuk lagi untuk menyimpan sisanya.$_temp0';
  }

  @override
  String pendingSummaryAuthNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tidak ada tautan yang tersimpan. Masuk lagi untuk menyimpan sisanya.$_temp0';
  }

  @override
  String pendingSummaryAuthPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan. Masuk lagi untuk menyimpan sisanya.$_temp0';
  }

  @override
  String pendingSummaryRetrySingleNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tautan tidak tersimpan. Coba lagi.$_temp0';
  }

  @override
  String pendingSummaryRetryNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tidak ada tautan yang tersimpan. Coba lagi.$_temp0';
  }

  @override
  String pendingSummaryRetryPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan. Coba lagi.$_temp0';
  }

  @override
  String get pendingSummaryAllSavedSingle => 'Tautan tersimpan ke akun Anda.';

  @override
  String pendingSummaryAllSaved(int total) {
    return 'Semua $total tautan tersimpan ke akun Anda.';
  }

  @override
  String pendingSummaryNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tidak ada tautan yang tersimpan.$_temp0';
  }

  @override
  String pendingSummaryPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining tautan masih ada di perangkat ini.',
      zero: '',
    );
    return 'Tersimpan $saved dari $total tautan.$_temp0';
  }

  @override
  String get saved => 'Tersimpan.';

  @override
  String get invalidUrlFull =>
      'Tautan itu tampaknya tidak valid. Masukkan alamat http:// atau https:// lengkap.';

  @override
  String get saveValidation =>
      'Tautan itu tampaknya tidak valid. Periksa URL dan coba lagi.';

  @override
  String get saveMalformed =>
      'Terjadi kesalahan saat mengirim tautan itu. Coba lagi.';

  @override
  String get saveRateLimitedNoWait =>
      'Anda menyimpan terlalu cepat. Coba lagi sebentar lagi.';

  @override
  String saveRateLimitedWithWait(String wait) {
    return 'Anda menyimpan terlalu cepat. Coba lagi dalam $wait.';
  }

  @override
  String get saveServerUnavailable =>
      'Kami tidak dapat menyimpan tautan ini saat ini. Coba lagi sebentar lagi.';

  @override
  String get saveUnreadable =>
      'Kami tidak dapat membaca balasan server, sehingga tidak dapat memastikan penyimpanan. Periksa Inbox Anda sebelum mencoba lagi.';

  @override
  String get saveTransport =>
      'Kami tidak dapat memastikan penyimpanan ini. Mungkin berhasil atau tidak — periksa Inbox Anda sebelum mencoba lagi.';

  @override
  String get saveRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga tautan itu tidak tersimpan. Coba lagi.';

  @override
  String get saveCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga tautan itu tidak tersimpan. Coba lagi.';

  @override
  String get saveAuthRequired => 'Masuk lagi untuk menyimpan tautan ini.';

  @override
  String get pageReRead => 'Halaman dibaca ulang.';

  @override
  String get pageReReadNoDetails =>
      'Halaman dibaca ulang. Halaman ini tidak menampilkan detail.';

  @override
  String get pageReadFailed => 'Tidak dapat membaca halaman ini.';

  @override
  String get enrichUnconfirmed =>
      'Kami tidak dapat memastikan pembacaan ulang. Coba lagi.';

  @override
  String get enrichRateLimitedNoWait =>
      'Anda terlalu sering membaca ulang halaman. Coba lagi sebentar lagi.';

  @override
  String enrichRateLimitedWithWait(String wait) {
    return 'Anda terlalu sering membaca ulang halaman. Coba lagi dalam $wait.';
  }

  @override
  String get enrichUnavailable =>
      'Pembacaan ulang untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get itemUnavailable => 'Item ini sudah tidak tersedia.';

  @override
  String get enrichAuthRequired =>
      'Masuk lagi untuk membaca ulang halaman ini.';

  @override
  String get enrichRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga halaman tidak dibaca ulang. Coba lagi.';

  @override
  String get enrichCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga halaman tidak dibaca ulang. Coba lagi.';

  @override
  String get enrichFailed =>
      'Kami tidak dapat membaca ulang halaman ini. Coba lagi.';

  @override
  String get enrichServerFault =>
      'Terjadi kesalahan saat membaca ulang halaman ini. Coba lagi.';

  @override
  String get moveServerError =>
      'Terjadi kesalahan saat memindahkan item ini. Coba lagi.';

  @override
  String get moveUnconfirmed =>
      'Kami tidak dapat memastikan pemindahan. Periksa koleksi item ini.';

  @override
  String get moveAuthRequired => 'Masuk lagi untuk memindahkan item ini.';

  @override
  String get moveRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga item tidak dipindahkan. Coba lagi.';

  @override
  String get moveCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga item tidak dipindahkan. Coba lagi.';

  @override
  String get moveMalformed =>
      'Terjadi kesalahan saat mengirim nama itu. Coba lagi.';

  @override
  String get moveRateLimitedNoWait =>
      'Anda memindahkan terlalu cepat. Coba lagi sebentar lagi.';

  @override
  String moveRateLimitedWithWait(String wait) {
    return 'Anda memindahkan terlalu cepat. Coba lagi dalam $wait.';
  }

  @override
  String alreadyInCollection(String name) {
    return 'Sudah ada di $name.';
  }

  @override
  String createdCollectionAndMoved(String name) {
    return '$name dibuat dan item dipindahkan.';
  }

  @override
  String movedToCollection(String name) {
    return 'Dipindahkan ke $name.';
  }

  @override
  String get itemDeleted => 'Item dihapus.';

  @override
  String itemDeletedAndCollectionDeleted(String name) {
    return 'Item dihapus, dan $name juga dihapus.';
  }

  @override
  String get deleteItemUnconfirmed =>
      'Kami tidak dapat memastikan apakah item dihapus. Periksa Inbox sebelum mencoba lagi.';

  @override
  String get deleteItemAuthRequired => 'Masuk lagi untuk menghapus item ini.';

  @override
  String get deleteItemRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga item tidak dihapus. Coba lagi.';

  @override
  String get deleteItemCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga item tidak dihapus. Coba lagi.';

  @override
  String get itemNotDeleted => 'Item tidak dihapus. Coba lagi.';

  @override
  String get deleteItemRateLimited =>
      'Anda terlalu cepat. Item tidak dihapus. Coba lagi sebentar lagi.';

  @override
  String collectionUnavailableAfterItemDeleted(String name) {
    return 'Item dihapus. $name sudah tidak tersedia.';
  }

  @override
  String collectionNotEmptyAfterItemDeleted(String name) {
    return 'Item dihapus. $name sekarang memiliki item, sehingga tidak dihapus.';
  }

  @override
  String collectionProtectedAfterItemDeleted(String name) {
    return 'Item dihapus. $name tidak dapat dihapus.';
  }

  @override
  String collectionDeleteUnconfirmedAfterItemDeleted(String name) {
    return 'Item dihapus, tetapi kami tidak dapat memastikan apakah $name dihapus. Periksa Koleksi.';
  }

  @override
  String collectionDeleteAuthRequiredAfterItemDeleted(String name) {
    return 'Item dihapus. Masuk lagi untuk menghapus $name.';
  }

  @override
  String collectionDeleteSessionEndedAfterItemDeleted(String name) {
    return 'Item dihapus. Sesi Anda berakhir sebelum $name dapat dihapus.';
  }

  @override
  String collectionDeleteRefreshUncertainAfterItemDeleted(String name) {
    return 'Item dihapus. Kami tidak dapat memperbarui sesi Anda, sehingga $name tidak dihapus. Coba lagi.';
  }

  @override
  String collectionDeleteCredentialStorageAfterItemDeleted(String name) {
    return 'Item dihapus. Perangkat ini tidak dapat memperbarui sesi Anda, sehingga $name tidak dihapus. Coba lagi.';
  }

  @override
  String collectionDeleteRateLimitedAfterItemDeleted(String name) {
    return 'Item dihapus. Anda terlalu cepat, sehingga $name tidak dihapus. Coba lagi sebentar lagi.';
  }

  @override
  String collectionDeleteFailedAfterItemDeleted(String name) {
    return 'Item dihapus, tetapi $name tidak dapat dihapus. Coba lagi dari Koleksi.';
  }

  @override
  String collectionDeleted(String name) {
    return '$name dihapus.';
  }

  @override
  String collectionDeletedItemsMoved(String name, String target) {
    return '$name dihapus, dan item-itemnya dipindahkan ke $target.';
  }

  @override
  String get collectionDeleteFailed => 'Koleksi tidak dihapus. Coba lagi.';

  @override
  String collectionDeleteTargetUnavailable(String name) {
    return '$name sudah tidak tersedia. Tidak ada yang diubah. Pilih tujuan lain.';
  }

  @override
  String collectionUnavailable(String name) {
    return '$name sudah tidak tersedia.';
  }

  @override
  String collectionNotEmpty(String name) {
    return '$name sekarang memiliki item, sehingga tidak ada yang diubah. Isinya sedang disegarkan.';
  }

  @override
  String collectionProtected(String name) {
    return '$name tidak dapat dihapus.';
  }

  @override
  String collectionDeleteUnconfirmed(String name) {
    return 'Kami tidak dapat memastikan apakah $name dihapus. Periksa Koleksi sebelum mencoba lagi.';
  }

  @override
  String get collectionDeleteAuthRequired =>
      'Masuk lagi untuk menghapus koleksi ini.';

  @override
  String collectionDeleteRefreshUncertain(String name) {
    return 'Kami tidak dapat memperbarui sesi Anda, sehingga $name tidak dihapus. Coba lagi.';
  }

  @override
  String collectionDeleteCredentialStorage(String name) {
    return 'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga $name tidak dihapus. Coba lagi.';
  }

  @override
  String get collectionDeleteRateLimitedNoWait =>
      'Anda terlalu cepat. Koleksi tidak dihapus. Coba lagi sebentar lagi.';

  @override
  String collectionDeleteRateLimitedWithWait(String wait) {
    return 'Anda terlalu cepat. Koleksi tidak dihapus. Coba lagi dalam $wait.';
  }

  @override
  String get linkCannotOpen => 'Tautan ini tidak dapat dibuka.';

  @override
  String get linkLaunchFailed =>
      'Kami tidak dapat membuka tautan ini. Coba lagi.';

  @override
  String get urlCopied => 'URL disalin';

  @override
  String get urlCopyFailed => 'Tidak dapat menyalin URL. Coba lagi.';

  @override
  String get refreshFailed => 'Tidak dapat menyegarkan. Periksa koneksi Anda.';

  @override
  String get displayNameUpdated => 'Nama tampilan diperbarui.';

  @override
  String get displayNameRateLimitedNoWait =>
      'Terlalu banyak percobaan. Coba lagi sebentar lagi.';

  @override
  String displayNameRateLimitedWithWait(String wait) {
    return 'Terlalu banyak percobaan. Coba lagi dalam $wait.';
  }

  @override
  String get displayNameUnavailable =>
      'Perubahan nama tampilan untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get displayNameUnconfirmed =>
      'Kami tidak dapat memastikan apakah nama tampilan Anda diperbarui. Periksa profil Anda sebelum mencoba lagi.';

  @override
  String get accountUnavailable => 'Akun ini sudah tidak tersedia.';

  @override
  String get displayNameAuthRequired =>
      'Masuk lagi untuk mengubah nama tampilan Anda.';

  @override
  String get displayNameRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga nama tampilan Anda tidak diubah. Coba lagi.';

  @override
  String get displayNameCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga nama tampilan Anda tidak diubah. Coba lagi.';

  @override
  String get displayNameChangeFailed =>
      'Kami tidak dapat mengubah nama tampilan Anda. Coba lagi.';

  @override
  String get passwordChanged => 'Kata sandi diubah.';

  @override
  String get passwordCreated => 'Kata sandi dibuat.';

  @override
  String get passwordModeConflictExists =>
      'Kata sandi sudah dibuat untuk akun ini. Buka layar ini lagi untuk mengubahnya.';

  @override
  String get passwordModeConflictRequired =>
      'Akun Anda sudah memiliki kata sandi. Buka layar ini lagi untuk mengubahnya.';

  @override
  String get passwordModeConflictUnexpected =>
      'Akun Anda belum memiliki kata sandi. Buka layar ini lagi untuk membuatnya.';

  @override
  String get passwordRateLimitedNoWait =>
      'Kami tidak dapat mengatur kata sandi saat ini. Coba lagi sebentar lagi.';

  @override
  String passwordRateLimitedWithWait(String wait) {
    return 'Kami tidak dapat mengatur kata sandi saat ini. Coba lagi dalam $wait.';
  }

  @override
  String get passwordUnavailable =>
      'Kami tidak dapat mengatur kata sandi saat ini. Coba lagi sebentar lagi.';

  @override
  String get passwordUnconfirmed =>
      'Kami tidak dapat memastikan apakah kata sandi Anda telah diatur. Buka layar ini lagi sebelum mencoba lagi.';

  @override
  String get passwordAuthRequired =>
      'Masuk lagi untuk mengatur kata sandi Anda.';

  @override
  String get passwordRefreshUncertainChanged =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga kata sandi Anda tidak diubah. Coba lagi.';

  @override
  String get passwordRefreshUncertainSet =>
      'Kami tidak dapat memperbarui sesi Anda, sehingga kata sandi Anda tidak diatur. Coba lagi.';

  @override
  String get passwordCredentialStorageChanged =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga kata sandi Anda tidak diubah. Coba lagi.';

  @override
  String get passwordCredentialStorageSet =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, sehingga kata sandi Anda tidak diatur. Coba lagi.';

  @override
  String get passwordSetFailed =>
      'Kami tidak dapat mengatur kata sandi Anda. Coba lagi.';

  @override
  String get newPinSent => 'PIN baru telah dikirim.';

  @override
  String get pinVerifiedProgressNotSaved =>
      'PIN terverifikasi, tetapi perangkat ini tidak dapat menyimpan kemajuan Anda. Selesaikan sebelum menutup aplikasi.';

  @override
  String get shareSaved => 'Disimpan ke akun Anda.';

  @override
  String get shareStoredAfterFailure =>
      'Gagal disimpan. Tetap disimpan di perangkat ini.';

  @override
  String get shareStoredAfterUncertain =>
      'Belum terkonfirmasi. Tetap disimpan di perangkat ini.';

  @override
  String get shareInvalid => 'Itu bukan tautan, jadi tidak ada yang disimpan.';

  @override
  String get shareNotStored =>
      'Tidak dapat menyimpan atau mempertahankan tautan ini.';

  @override
  String get inboxTitle => 'INBOX';

  @override
  String get inboxRecentlySaved => 'BARU DISIMPAN';

  @override
  String get inboxLoadingMore => 'Memuat lagi…';

  @override
  String get inboxEmptyTitle => 'Belum ada yang disimpan';

  @override
  String get inboxEmptyBody =>
      'Simpan tautan dan tautan itu akan muncul di sini, di koleksi tempatnya berada.';

  @override
  String get inboxRetry => 'Coba lagi';

  @override
  String get inboxSessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk melihat item tersimpan Anda.';

  @override
  String get inboxSignInRequired =>
      'Masuk lagi untuk melihat item tersimpan Anda.';

  @override
  String get inboxUnavailable =>
      'Item tersimpan Anda untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get inboxLoadTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memuat item tersimpan Anda.';

  @override
  String get inboxLoadGeneric =>
      'Kami tidak dapat memuat item tersimpan Anda. Coba lagi.';

  @override
  String get inboxSaveUrlSection => 'SIMPAN URL';

  @override
  String get inboxSaving => 'Menyimpan…';

  @override
  String get inboxIntakeReady => 'Periksa atau edit tautan sebelum menyimpan.';

  @override
  String get inboxIntakeHint =>
      'Tempel mengisi kolom. Simpan URL mengirimkannya.';

  @override
  String get inboxPaste => 'Tempel';

  @override
  String get inboxSaveAction => 'Simpan URL';

  @override
  String get inboxYourNote => 'Catatan Anda';

  @override
  String get pendingUrlsTitle => 'DISIMPAN DI PERANGKAT INI';

  @override
  String get pendingUrlsBackToInbox => 'Kembali ke Inbox';

  @override
  String get pendingUrlsBackToSignIn => 'Kembali ke halaman masuk';

  @override
  String get pendingUrlsLoading => 'Memuat tautan…';

  @override
  String get pendingUrlsSignedInIntro =>
      'Tautan yang Anda bagikan disimpan di sini selama tujuh hari jika penyimpanan tidak selesai. Tautan tersebut disimpan di perangkat ini sampai Anda menyimpannya ke akun.';

  @override
  String get pendingUrlsSignedOutIntro =>
      'Tautan yang Anda bagikan disimpan di sini selama tujuh hari jika penyimpanan tidak selesai. Tautan tersebut disimpan di perangkat ini, bukan di akun Anda.';

  @override
  String get pendingUrlsSaveAllAction => 'Simpan semua ke akun saya';

  @override
  String get pendingUrlsSignInAction => 'Masuk untuk menyimpan tautan ini';

  @override
  String get pendingUrlsSaving => 'Menyimpan…';

  @override
  String pendingUrlsSavingProgress(int current, int total) {
    return 'Menyimpan $current dari $total…';
  }

  @override
  String get pendingUrlsSaveNotConfirmed => 'Penyimpanan belum dikonfirmasi';

  @override
  String get pendingUrlsEmptyTitle =>
      'Tidak ada yang disimpan di perangkat ini';

  @override
  String get pendingUrlsEmptyBody =>
      'Tautan yang penyimpanannya tidak selesai akan muncul di sini selama tujuh hari.';

  @override
  String get pendingUrlsReadError =>
      'Kami tidak dapat membaca tautan yang disimpan di perangkat ini.';

  @override
  String get pendingUrlsRetry => 'Coba lagi';

  @override
  String get pendingUrlsKeptJustNow => 'Baru saja disimpan';

  @override
  String pendingUrlsKeptMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count menit lalu',
    );
    return '$_temp0';
  }

  @override
  String pendingUrlsKeptHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count jam lalu',
    );
    return '$_temp0';
  }

  @override
  String get pendingUrlsKeptYesterday => 'Disimpan kemarin';

  @override
  String pendingUrlsKeptDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan $count hari lalu',
    );
    return '$_temp0';
  }

  @override
  String get pendingUrlsEntryTitle => 'Disimpan di perangkat ini';

  @override
  String get pendingUrlsEntryActiveBody =>
      'Disimpan di perangkat ini. Buka untuk meninjaunya.';

  @override
  String get pendingUrlsEntryEmptyBody =>
      'Tautan yang tidak dapat disimpan akan muncul di sini.';

  @override
  String pendingUrlsEntrySemanticsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disimpan di perangkat ini, $count tautan',
    );
    return '$_temp0';
  }

  @override
  String get pendingUrlsEntrySemanticsOverflow =>
      'Disimpan di perangkat ini, lebih dari 99 tautan';

  @override
  String get savedItemDetailTitle => 'ITEM';

  @override
  String get savedItemCollectionDetailTitle => 'KOLEKSI';

  @override
  String get savedItemBackToInbox => 'Kembali ke Inbox';

  @override
  String get savedItemActionsSection => 'TINDAKAN';

  @override
  String get savedItemMoveAction => 'Pindahkan ke koleksi';

  @override
  String get savedItemOpenAction => 'Buka halaman asli';

  @override
  String get savedItemCopyUrl => 'Salin URL';

  @override
  String get savedItemShareUrl => 'Bagikan URL';

  @override
  String get savedItemPriceMayHaveChanged => 'Harga mungkin sudah berubah.';

  @override
  String get savedItemAddNote => 'Tambahkan catatan pribadi';

  @override
  String get savedItemNoteSaveAction => 'Simpan';

  @override
  String get savedItemNotePlaceholder => 'Tulis catatan Anda…';

  @override
  String savedItemNoteCharacterCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get savedItemNoteDeleteTitle => 'Hapus catatan ini?';

  @override
  String get savedItemNoteDeleteMessage =>
      'Ini menghapus catatan Anda. Item tersimpan tetap ada.';

  @override
  String get savedItemNoteKeepAction => 'Pertahankan catatan';

  @override
  String get savedItemNoteDeleteConfirmAction => 'Hapus catatan';

  @override
  String get savedItemNoteSaved => 'Catatan disimpan.';

  @override
  String get savedItemNoteDeleted => 'Catatan dihapus.';

  @override
  String get savedItemNoteSaveUnconfirmed =>
      'Kami tidak dapat memastikan apakah catatan Anda tersimpan. Periksa catatan sebelum mencoba lagi.';

  @override
  String get savedItemNoteDeleteUnconfirmed =>
      'Kami tidak dapat memastikan apakah catatan Anda terhapus. Periksa catatan sebelum mencoba lagi.';

  @override
  String get savedItemNoteAuthRequired =>
      'Masuk lagi untuk mengubah catatan ini.';

  @override
  String get savedItemNoteRefreshUncertain =>
      'Kami tidak dapat memperbarui sesi Anda, jadi catatan tidak diubah. Coba lagi.';

  @override
  String get savedItemNoteCredentialStorage =>
      'Perangkat ini tidak dapat memperbarui sesi Anda, jadi catatan tidak diubah. Coba lagi.';

  @override
  String get savedItemNoteRateLimitedNoWait =>
      'Anda mengubah catatan terlalu cepat. Coba lagi sebentar lagi.';

  @override
  String savedItemNoteRateLimitedWithWait(String wait) {
    return 'Anda mengubah catatan terlalu cepat. Coba lagi dalam $wait.';
  }

  @override
  String get savedItemNoteUnavailable =>
      'Perubahan catatan untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get savedItemNoteInvalid =>
      'Catatan itu tidak dapat disimpan. Periksa teksnya dan coba lagi.';

  @override
  String get savedItemNoteSaveFailed =>
      'Kami tidak dapat menyimpan catatan Anda. Coba lagi.';

  @override
  String get savedItemNoteDeleteFailed =>
      'Kami tidak dapat menghapus catatan Anda. Coba lagi.';

  @override
  String get savedItemDeleteAction => 'Hapus item ini';

  @override
  String get savedItemEnrichmentSection => 'PENGAYAAN';

  @override
  String get savedItemReReadAction => 'Baca ulang halaman';

  @override
  String get savedItemReadingPage => 'Membaca halaman…';

  @override
  String get savedItemDeleteDialogTitle => 'Hapus item ini?';

  @override
  String get savedItemDeleteDialogMessage =>
      'Tindakan ini menghapus item tersimpan. Tidak dapat dibatalkan.';

  @override
  String get savedItemKeepAction => 'Pertahankan';

  @override
  String get savedItemDeleteConfirmAction => 'Hapus';

  @override
  String savedItemCollectionEmptyTitle(String name) {
    return '$name sekarang kosong';
  }

  @override
  String savedItemCollectionEmptyMessage(String name) {
    return 'Ini adalah item terakhir di $name. Anda dapat mempertahankan koleksi kosong ini atau menghapusnya.';
  }

  @override
  String get savedItemKeepCollectionAction => 'Pertahankan';

  @override
  String get savedItemDeleteCollectionAction => 'Hapus koleksi';

  @override
  String get savedItemCancelAction => 'Batal';

  @override
  String get savedItemKeepCollectionDismissAction => 'Pertahankan koleksi';

  @override
  String get savedItemCloseAction => 'Tutup';

  @override
  String get savedItemNotFoundTitle => 'Item ini sudah tidak tersedia';

  @override
  String get savedItemNotFoundBody =>
      'Item ini mungkin sudah dihapus, atau mungkin milik akun lain.';

  @override
  String get savedItemLoadErrorTitle => 'Kami tidak dapat memuat item ini';

  @override
  String get savedItemRetry => 'Coba lagi';

  @override
  String get savedItemSessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk melihat item ini.';

  @override
  String get savedItemSignInRequired => 'Masuk lagi untuk melihat item ini.';

  @override
  String get savedItemUnavailable =>
      'Item ini untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get savedItemLoadTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memuat item ini.';

  @override
  String get savedItemLoadGeneric =>
      'Kami tidak dapat memuat item ini. Coba lagi.';

  @override
  String get savedItemEnrichmentReading => 'Membaca halaman…';

  @override
  String get savedItemEnrichmentNoDetails => 'Tidak ada detail di halaman ini';

  @override
  String get savedItemEnrichmentFailed => 'Tidak dapat membaca halaman ini';

  @override
  String get savedItemBackToCollections => 'Kembali ke Koleksi';

  @override
  String get savedItemCollectionActionsTooltip => 'Tindakan koleksi';

  @override
  String get savedItemLoadingMore => 'Memuat lagi…';

  @override
  String get savedItemLoadMoreFailed => 'Tidak dapat memuat item lainnya.';

  @override
  String get savedItemEmptyCollectionTitle => 'Belum ada yang disimpan di sini';

  @override
  String get savedItemEmptyCollectionBody =>
      'Item yang disimpan ke koleksi ini akan muncul di sini.';

  @override
  String get savedItemCollectionUnavailableTitle =>
      'Koleksi ini sudah tidak tersedia';

  @override
  String get savedItemCollectionUnavailableBody =>
      'Koleksi ini mungkin sudah dihapus, atau mungkin milik akun lain.';

  @override
  String get savedItemCollectionLoadErrorTitle =>
      'Kami tidak dapat memuat koleksi ini';

  @override
  String get savedItemCollectionSessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk melihat koleksi ini.';

  @override
  String get savedItemCollectionSignInRequired =>
      'Masuk lagi untuk melihat koleksi ini.';

  @override
  String get savedItemCollectionUnavailable =>
      'Koleksi ini untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get savedItemCollectionLoadTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memuat koleksi ini.';

  @override
  String get savedItemCollectionLoadGeneric =>
      'Kami tidak dapat memuat koleksi ini. Coba lagi.';

  @override
  String get savedItemEmptyCollectionDeleteTitle => 'Hapus koleksi ini?';

  @override
  String savedItemDeleteCollectionNamedTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get savedItemEmptyCollectionDeleteMessage =>
      'Koleksi ini kosong. Tidak ada item untuk dipertahankan atau dibuang. Tindakan ini tidak dapat dibatalkan.';

  @override
  String savedItemCurrentlyIn(String name) {
    return 'Saat ini di $name';
  }

  @override
  String get savedItemYourCollections => 'KOLEKSI ANDA';

  @override
  String get savedItemBrowseAllCollections => 'Jelajahi semua koleksi';

  @override
  String get savedItemNewCollection => 'Koleksi baru';

  @override
  String get savedItemNewCollectionPlaceholder => 'mis. Daftar bacaan';

  @override
  String get savedItemLoadingCollections => 'Memuat koleksi…';

  @override
  String get savedItemLoadCollectionsFailed =>
      'Kami tidak dapat memuat koleksi Anda.';

  @override
  String get savedItemBrowseAllHint =>
      'Jelajahi semua koleksi untuk menemukan tujuan.';

  @override
  String get savedItemNoOtherCollectionsCreate =>
      'Belum ada koleksi lain. Buat satu di bawah.';

  @override
  String savedItemAlreadyIn(String name) {
    return 'Sudah ada di $name';
  }

  @override
  String savedItemMoveTo(String name) {
    return 'Pindahkan ke $name';
  }

  @override
  String savedItemCreate(String name) {
    return 'Buat $name';
  }

  @override
  String get savedItemMoveHelperError =>
      'Anda tetap dapat membuat koleksi berdasarkan nama, atau menjelajahi semua koleksi.';

  @override
  String get savedItemMoveHelper =>
      'Pilih koleksi yang ada, atau masukkan nama untuk membuat koleksi baru.';

  @override
  String get savedItemCollectionNameTaken =>
      'Nama koleksi itu sudah digunakan. Pilih nama lain.';

  @override
  String get savedItemCollectionNameRequired => 'Masukkan nama koleksi.';

  @override
  String get savedItemCollectionNameTooLong =>
      'Gunakan 100 karakter atau kurang.';

  @override
  String get savedItemCollectionNameRange =>
      'Masukkan nama koleksi antara 1 dan 100 karakter.';

  @override
  String get savedItemAllCollections => 'Semua koleksi';

  @override
  String get savedItemPickerDescription =>
      'Pilih koleksi untuk memindahkan item ini.';

  @override
  String get savedItemNoOtherCollections => 'Belum ada koleksi lain.';

  @override
  String get savedItemLoadMoreCollectionsFailed =>
      'Kami tidak dapat memuat koleksi lainnya.';

  @override
  String get savedItemThisCollection => 'Koleksi ini';

  @override
  String get savedItemTheCollection => 'koleksi';

  @override
  String get savedItemDeleteCollectionCannotUndo =>
      'Menghapus koleksi tidak dapat dibatalkan, dan item yang Anda pilih untuk dihapus tidak dapat dipulihkan.';

  @override
  String get savedItemMoveItemsAction => 'Pindahkan item ke koleksi lain';

  @override
  String get savedItemDeleteItemsAction => 'Hapus koleksi dan item';

  @override
  String get savedItemCollectionHasItemsUnknown =>
      'Koleksi ini memiliki item tersimpan. Pilih yang terjadi pada item tersebut.';

  @override
  String savedItemCollectionHasItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Koleksi ini memiliki $count item tersimpan. Pilih yang terjadi pada item tersebut.',
    );
    return '$_temp0';
  }

  @override
  String savedItemBulkMoveThisItem(String name) {
    return 'Pilih tujuan item ini. $name akan dihapus.';
  }

  @override
  String savedItemBulkMoveTheseItems(String name) {
    return 'Pilih tujuan item-item ini. $name akan dihapus.';
  }

  @override
  String get collectionsTitle => 'KOLEKSI';

  @override
  String get collectionsSortNewest => 'Terbaru';

  @override
  String get collectionsSortOldest => 'Terlama';

  @override
  String get collectionsSortName => 'Nama';

  @override
  String get collectionsEmptyTitle => 'Belum ada koleksi';

  @override
  String get collectionsEmptyBody =>
      'Koleksi muncul saat Anda menyimpan tautan atau mengaturnya.';

  @override
  String get collectionsRetry => 'Coba lagi';

  @override
  String get collectionsSessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk melihat koleksi Anda.';

  @override
  String get collectionsSignInRequired =>
      'Masuk lagi untuk melihat koleksi Anda.';

  @override
  String get collectionsUnavailable =>
      'Koleksi Anda untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get collectionsLoadTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memuat koleksi Anda.';

  @override
  String get collectionsLoadGeneric =>
      'Kami tidak dapat memuat koleksi Anda. Coba lagi.';

  @override
  String get collectionsSystemBadge => 'sistem';

  @override
  String collectionsSavedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item tersimpan',
    );
    return '$_temp0';
  }

  @override
  String get collectionsSavedItemsCountOverflow =>
      'Lebih dari 99 item tersimpan';

  @override
  String get searchTitle => 'CARI';

  @override
  String get searchPlaceholder => 'Cari item tersimpan dan koleksi';

  @override
  String get searchInitialTitle => 'Temukan sesuatu yang Anda simpan';

  @override
  String get searchInitialBody =>
      'Pencarian mencocokkan judul item, domain, URL, dan nama koleksi.';

  @override
  String searchNoMatchesTitle(String query) {
    return 'Tidak ada hasil untuk ‘$query’';
  }

  @override
  String get searchNoMatchesBody =>
      'Item mungkin masih cocok berdasarkan judul, domain, URL, atau nama koleksi. Coba kata lain, atau jelajahi Koleksi.';

  @override
  String get searchQueryRequired => 'Masukkan sesuatu untuk dicari.';

  @override
  String searchQueryTooShort(int min) {
    return 'Pencarian membutuhkan setidaknya $min karakter.';
  }

  @override
  String searchQueryTooLong(int max) {
    return 'Pencarian dibatasi $max karakter. Persingkat dan coba lagi.';
  }

  @override
  String get searchSearchingSemantics => 'Mencari';

  @override
  String get searchFailureTitle => 'Pencarian tidak berjalan';

  @override
  String searchValidationFailure(int min, int max) {
    return 'Pencarian membutuhkan antara $min dan $max karakter. Periksa pencarian Anda dan coba lagi.';
  }

  @override
  String get searchSessionEnded =>
      'Sesi Anda telah berakhir. Masuk lagi untuk mencari.';

  @override
  String get searchSignInRequired => 'Masuk lagi untuk mencari.';

  @override
  String get searchRateLimitedNoWait =>
      'Terlalu banyak pencarian. Coba lagi sebentar lagi.';

  @override
  String searchRateLimitedWithWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Terlalu banyak pencarian. Coba lagi dalam $seconds detik.',
    );
    return '$_temp0';
  }

  @override
  String get searchUnavailable =>
      'Pencarian untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get searchTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat menjalankan pencarian Anda.';

  @override
  String get searchFailureGeneric =>
      'Kami tidak dapat menjalankan pencarian Anda. Coba lagi.';

  @override
  String get searchRetry => 'Coba lagi';

  @override
  String get searchCollectionsHeading => 'KOLEKSI';

  @override
  String get searchSavedItemsHeading => 'ITEM TERSIMPAN';

  @override
  String get profileTitle => 'PROFIL';

  @override
  String get profileSignOut => 'Keluar';

  @override
  String get profileLoading => 'Memuat profil…';

  @override
  String get profileRetry => 'Coba lagi';

  @override
  String get profileSessionEnded => 'Sesi Anda telah berakhir. Masuk lagi.';

  @override
  String get profileSignInRequired => 'Masuk lagi untuk melihat profil Anda.';

  @override
  String get profileUnavailable =>
      'Profil untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get profileTransport =>
      'Tidak ada koneksi. Kami tidak dapat memuat profil Anda.';

  @override
  String get profileLoadGeneric =>
      'Kami tidak dapat memuat profil Anda. Coba lagi.';

  @override
  String get profileAccountSection => 'AKUN';

  @override
  String get profileLinkedIdentitiesSection => 'IDENTITAS TERTAUT';

  @override
  String get profileDisplayNameLabel => 'Nama tampilan';

  @override
  String get profileChangePasswordAction => 'Ubah kata sandi';

  @override
  String get profileCreatePasswordAction => 'Buat kata sandi';

  @override
  String get profileNoAccountsConnected => 'Belum ada akun yang terhubung.';

  @override
  String profileJoinedDate(String date) {
    return 'bergabung $date';
  }

  @override
  String profileLinkedDate(String date) {
    return 'tertaut $date';
  }

  @override
  String get profilePasswordTitle => 'KATA SANDI';

  @override
  String get profileChangePasswordTitle => 'UBAH KATA SANDI';

  @override
  String get profileCreatePasswordTitle => 'BUAT KATA SANDI';

  @override
  String get profileBackToProfile => 'Kembali ke Profil';

  @override
  String get profileChangePasswordDescription =>
      'Pilih kata sandi baru untuk akun Anda.';

  @override
  String get profileCreatePasswordDescription =>
      'Tambahkan kata sandi agar Anda dapat masuk dengan alamat email.';

  @override
  String get profileCurrentPasswordLabel => 'Kata sandi saat ini';

  @override
  String get profileNewPasswordLabel => 'Kata sandi baru';

  @override
  String get profileConfirmNewPasswordLabel => 'Konfirmasi kata sandi baru';

  @override
  String get profileShowCurrentPassword => 'Tampilkan kata sandi saat ini';

  @override
  String get profileHideCurrentPassword => 'Sembunyikan kata sandi saat ini';

  @override
  String get profileShowNewPassword => 'Tampilkan kata sandi baru';

  @override
  String get profileHideNewPassword => 'Sembunyikan kata sandi baru';

  @override
  String get profileShowConfirmationPassword =>
      'Tampilkan konfirmasi kata sandi';

  @override
  String get profileHideConfirmationPassword =>
      'Sembunyikan konfirmasi kata sandi';

  @override
  String get profileCurrentPasswordRequired => 'Masukkan kata sandi saat ini.';

  @override
  String get profilePasswordLength => 'Gunakan antara 8 dan 128 karakter.';

  @override
  String get profilePasswordsDoNotMatch => 'Kata sandi tidak cocok.';

  @override
  String get profileCurrentPasswordIncorrect => 'Kata sandi saat ini salah.';

  @override
  String get profilePasswordChangedElsewhere =>
      'Kata sandi Anda diubah di tempat lain. Masukkan kata sandi saat ini lagi.';

  @override
  String get profileEditDisplayNameTitle => 'Edit nama tampilan';

  @override
  String get profileDisplayNameValidation =>
      'Gunakan antara 2 dan 100 karakter.';

  @override
  String get profileCancelAction => 'Batal';

  @override
  String get profileSaveAction => 'Simpan';

  @override
  String get authBackToWelcome => 'Kembali ke halaman awal';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Kata sandi';

  @override
  String get authPinLabel => 'PIN';

  @override
  String get authDisplayNameLabel => 'Nama tampilan';

  @override
  String get authConfirmPasswordLabel => 'Konfirmasi kata sandi';

  @override
  String get authNewPasswordLabel => 'Kata sandi baru';

  @override
  String get authConfirmNewPasswordLabel => 'Konfirmasi kata sandi baru';

  @override
  String get authShowPassword => 'Tampilkan kata sandi';

  @override
  String get authHidePassword => 'Sembunyikan kata sandi';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authSignInTitle => 'Masuk ke Stash It';

  @override
  String get authSignInDescription =>
      'Gunakan email dan kata sandi akun Stash It Anda.';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get authNoAccountPrompt => 'Belum punya akun?';

  @override
  String get authCreateAnAccount => 'Buat akun';

  @override
  String get authCreateAccount => 'Buat akun';

  @override
  String get authSignUpTitle => 'Buat akun Anda';

  @override
  String get authSignUpDescription =>
      'Masukkan alamat email Anda. Kami akan mengirimkan PIN untuk mengonfirmasinya.';

  @override
  String get authSendPin => 'Kirim PIN';

  @override
  String get authAlreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get authContinueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get authRetry => 'Coba lagi';

  @override
  String get authTryAgain => 'Coba lagi';

  @override
  String get authBackToSignIn => 'Kembali ke halaman masuk';

  @override
  String get authStartOver => 'Mulai ulang';

  @override
  String get authStartNewRegistration => 'Mulai pendaftaran baru';

  @override
  String get authStartNewReset => 'Mulai reset baru';

  @override
  String get authUseDifferentEmail => 'Gunakan email lain';

  @override
  String get authContinue => 'Lanjutkan';

  @override
  String get authCancel => 'Batal';

  @override
  String get authLinkAccount => 'Tautkan akun';

  @override
  String get authVerifyPin => 'Verifikasi PIN';

  @override
  String get authResendPin => 'Kirim ulang PIN';

  @override
  String authResendPinIn(int seconds) {
    return 'Kirim ulang PIN dalam $seconds dtk';
  }

  @override
  String get authSending => 'Mengirim…';

  @override
  String get authSendResetPin => 'Kirim PIN reset';

  @override
  String get authResetPassword => 'Reset kata sandi';

  @override
  String get authBackToPasswordReset => 'Kembali ke reset kata sandi';

  @override
  String get authReplaceSavedResetTitle =>
      'Ganti reset kata sandi yang tersimpan?';

  @override
  String get authKeepSavedReset => 'Pertahankan reset tersimpan';

  @override
  String get authReplaceAndVerify => 'Ganti dan verifikasi';

  @override
  String get authRecoverRegistration => 'Pulihkan pendaftaran ini';

  @override
  String get authEntryHeadline =>
      'Tempat untuk hal-hal yang Anda temukan di internet.';

  @override
  String get authEntryDescription =>
      'Simpan tautan dari browser apa pun, lalu temukan lagi di sini.';

  @override
  String get authCheckYourEmail => 'Periksa email Anda';

  @override
  String get authEnterYourPin => 'Masukkan PIN Anda';

  @override
  String get authCompleteYourAccount => 'Lengkapi akun Anda';

  @override
  String get authRegistrationUnavailable => 'Pendaftaran tidak tersedia';

  @override
  String get authResetUnavailable => 'Reset tidak tersedia';

  @override
  String get authResetPasswordTitle => 'Reset kata sandi Anda';

  @override
  String get authChooseNewPassword => 'Pilih kata sandi baru';

  @override
  String get authLinkYourGoogleAccount => 'Tautkan akun Google Anda';

  @override
  String get authEnterEmail => 'Masukkan alamat email Anda.';

  @override
  String get authInvalidEmail => 'Masukkan alamat email yang valid.';

  @override
  String get authEmailTooLong => 'Alamat email itu terlalu panjang.';

  @override
  String get authEnterPassword => 'Masukkan kata sandi Anda.';

  @override
  String get authPasswordMin8 => 'Kata sandi Anda minimal 8 karakter.';

  @override
  String get authPasswordTooLong => 'Kata sandi itu terlalu panjang.';

  @override
  String get authEnterNewPassword => 'Masukkan kata sandi baru.';

  @override
  String get authPasswordRange => 'Gunakan antara 8 dan 128 karakter.';

  @override
  String get authPasswordsDoNotMatch => 'Kata sandi tidak cocok.';

  @override
  String get authEnterDisplayName => 'Masukkan nama tampilan.';

  @override
  String get authDisplayNameMin2 => 'Nama tampilan minimal 2 karakter.';

  @override
  String get authDisplayNameTooLong => 'Nama tampilan terlalu panjang.';

  @override
  String get authEnterSixDigitPin => 'Masukkan PIN 6 digit.';

  @override
  String get authCheckEmailThenTryAgain =>
      'Periksa alamat email Anda, lalu coba lagi.';

  @override
  String get authCheckDetailsThenTryAgain =>
      'Periksa data Anda, lalu coba lagi.';

  @override
  String get authCheckDisplayNameThenTryAgain =>
      'Periksa nama tampilan Anda, lalu coba lagi.';

  @override
  String get authRegistrationSuccessSignIn =>
      'Pendaftaran berhasil. Silakan masuk dengan akun baru Anda.';

  @override
  String get authRegistrationUncertainSignIn =>
      'Kami tidak dapat memastikan apakah pendaftaran selesai. Coba masuk; jika gagal, mulai lagi.';

  @override
  String get authPasswordResetSuccessSignIn =>
      'Kata sandi Anda telah direset. Silakan masuk dengan kata sandi baru Anda.';

  @override
  String get authPasswordResetUncertainSignIn =>
      'Kami tidak dapat memastikan apakah reset kata sandi selesai. Coba masuk dengan kata sandi baru Anda.';

  @override
  String get authSignInGenericFailure =>
      'Terjadi kesalahan saat masuk. Coba lagi.';

  @override
  String get authSignInInvalidCredentials =>
      'Email atau kata sandi itu tampaknya tidak valid.';

  @override
  String get authSignInValidation =>
      'Periksa alamat email dan kata sandi Anda, lalu coba lagi.';

  @override
  String get authSignInUnavailable =>
      'Masuk untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authSignInUnconfirmed =>
      'Tidak ada koneksi ke server. Kami tidak dapat memastikan proses masuk ini.';

  @override
  String get authSessionUnconfirmed =>
      'Kami tidak dapat memastikan sesi Anda. Coba lagi.';

  @override
  String get authSignInStorageFailed =>
      'Proses masuk Anda tidak dapat disimpan dengan aman. Coba lagi.';

  @override
  String authTooManyAttemptsWithWait(int seconds) {
    return 'Terlalu banyak percobaan. Coba lagi dalam $seconds detik.';
  }

  @override
  String get authSignUpGenericFailure =>
      'Terjadi kesalahan saat memulai pendaftaran. Coba lagi.';

  @override
  String get authRegistrationMismatch =>
      'Kami tidak dapat mencocokkan pendaftaran itu dengan email ini. Coba lagi dengan alamat yang sama.';

  @override
  String get authRegistrationAlreadyCompletedSignIn =>
      'Pendaftaran ini sudah selesai. Silakan masuk.';

  @override
  String get authRecoveryCouldNotStart =>
      'Pemulihan tidak dapat dimulai. Coba lagi.';

  @override
  String get authRecoveryGenericFailure =>
      'Terjadi kesalahan saat memulai pemulihan. Coba lagi.';

  @override
  String get authRegistrationCheckTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memeriksa pendaftaran itu. Coba lagi.';

  @override
  String get authRegistrationCheckUnreadable =>
      'Kami tidak dapat membaca balasan server, sehingga tidak dapat memeriksa pendaftaran itu. Coba lagi.';

  @override
  String get authRegistrationCheckUnavailable =>
      'Kami tidak dapat memeriksa pendaftaran itu. Coba lagi sebentar lagi.';

  @override
  String get authRegistrationCheckGeneric =>
      'Kami tidak dapat memeriksa pendaftaran ini. Coba lagi.';

  @override
  String get authRecoveryTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memulai pemulihan. Coba lagi.';

  @override
  String get authRecoveryUnreadable =>
      'Kami tidak dapat memastikan apakah pemulihan dimulai. Coba lagi.';

  @override
  String get authRecoveryUnavailable =>
      'Pemulihan untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authRecoveryServerFault =>
      'Kami tidak dapat memulai pemulihan. Coba lagi sebentar lagi.';

  @override
  String authPinSentToEmail(String email) {
    return 'Kami mengirim PIN ke $email. Anda memerlukannya untuk menyelesaikan pembuatan akun.';
  }

  @override
  String get authVerificationComplete => 'Verifikasi sudah selesai';

  @override
  String authVerifiedSavedCodeUnconfirmed(String email) {
    return 'Kami tidak dapat memeriksa kode yang tersimpan di perangkat ini untuk $email. Coba lagi, atau pulihkan pendaftaran dengan PIN baru. Pemulihan akan menggantikan kode tersimpan di perangkat ini.';
  }

  @override
  String authVerifiedNoToken(String email) {
    return 'Email ini sudah diverifikasi, tetapi perangkat ini tidak memiliki kode yang diperlukan untuk menyelesaikannya. Pulihkan dengan PIN baru yang dikirim ke $email.';
  }

  @override
  String get authRegistrationAlreadyCompleted =>
      'Akun dengan email ini sudah ada. Silakan masuk.';

  @override
  String get authRegistrationAlreadyPending =>
      'Pendaftaran ini sudah menunggu PIN. Lanjutkan dengan langkah tersebut.';

  @override
  String get authRegistrationRetryable =>
      'Percobaan pendaftaran lain sedang berlangsung. Coba lagi.';

  @override
  String get authRegistrationIdentityMismatch =>
      'Pendaftaran untuk email ini sedang berlangsung dengan akun Google yang berbeda. Coba lagi setelah kedaluwarsa.';

  @override
  String get authRegistrationRestartRequired =>
      'Pendaftaran itu tidak dapat dilanjutkan lagi. Mulai pendaftaran baru.';

  @override
  String get authPinRecentlySent =>
      'PIN baru saja dikirim ke email ini. Coba lagi sebentar lagi.';

  @override
  String get authPinEmailUnconfirmed =>
      'Kami tidak dapat memastikan email PIN telah terkirim. Periksa kotak masuk Anda sebelum mencoba lagi.';

  @override
  String get authPinEmailUnconfirmedShort =>
      'Kami tidak dapat memastikan email PIN telah terkirim. Periksa kotak masuk Anda.';

  @override
  String get authRegistrationUnavailableShort =>
      'Pendaftaran untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authRegistrationServerFault =>
      'Server tidak dapat memulai pendaftaran Anda. Coba lagi sebentar lagi.';

  @override
  String get authRegistrationStartUnconfirmed =>
      'Tidak ada koneksi ke server. Kami tidak dapat memastikan apakah pendaftaran Anda dimulai.';

  @override
  String get authRegistrationStartUnreadable =>
      'Kami tidak dapat membaca balasan server, sehingga tidak dapat memastikan apakah pendaftaran Anda dimulai atau PIN telah dikirim. Periksa kotak masuk Anda sebelum mencoba lagi.';

  @override
  String get authRegistrationStartGeneric =>
      'Kami tidak dapat memulai pendaftaran Anda. Coba lagi.';

  @override
  String get authRegistrationAlreadyCompletedTitle =>
      'Pendaftaran sudah selesai';

  @override
  String get authRegistrationAlreadyCompletedBody =>
      'Pendaftaran ini sudah selesai. Masuk untuk melanjutkan.';

  @override
  String get authRegistrationCannotBeCompletedBody =>
      'Pendaftaran ini tidak dapat diselesaikan lagi. Mulai pendaftaran baru.';

  @override
  String authAccountForEmail(String email) {
    return 'Akun untuk $email';
  }

  @override
  String get authRegistrationStepClosed =>
      'Langkah pendaftaran ini sudah tidak terbuka. Mulai ulang dengan email yang sama untuk melanjutkan.';

  @override
  String get authRegistrationNotFound =>
      'Kami tidak dapat menemukan pendaftaran itu. Mulai pendaftaran baru.';

  @override
  String get authRegistrationUnreadable =>
      'Kami tidak dapat membaca pendaftaran itu. Mulai pendaftaran baru.';

  @override
  String get authPinInvalid => 'PIN itu tidak benar. Coba lagi.';

  @override
  String get authPinAttemptsExceededRegistration =>
      'Terlalu banyak PIN yang salah. Mulai pendaftaran baru.';

  @override
  String get authPinAttemptsExceededReset =>
      'Terlalu banyak PIN yang salah. Minta reset baru.';

  @override
  String get authVerificationUnavailable =>
      'Verifikasi untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authPinVerifyServerFault =>
      'Kami tidak dapat memverifikasi PIN Anda. Coba lagi sebentar lagi.';

  @override
  String get authPinVerifyTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memastikan PIN Anda.';

  @override
  String get authPinVerifyGeneric =>
      'Kami tidak dapat memverifikasi PIN Anda. Coba lagi.';

  @override
  String get authRegistrationCompleteGeneric =>
      'Kami tidak dapat menyelesaikan pendaftaran Anda. Coba lagi.';

  @override
  String get authPinInstructions =>
      'Kami mengirim PIN ke alamat email Anda. Masukkan di bawah untuk melanjutkan.';

  @override
  String authSocialVerifiedDescription(String email) {
    return 'Akun Google Anda sudah diverifikasi. Pilih nama yang akan ditampilkan di Stash-it untuk $email.';
  }

  @override
  String get authAccountAlreadyCreated => 'Akun sudah dibuat';

  @override
  String get authSocialAlreadyCompletedBody =>
      'Pendaftaran sosial ini sudah selesai. Lanjutkan dengan Google atau masuk untuk menggunakan akun.';

  @override
  String get authSocialInactiveBody =>
      'Pendaftaran sosial ini tidak dapat diselesaikan lagi. Mulai lagi dengan Google untuk membuat akun.';

  @override
  String get authAccountCreatedSignInNotSaved =>
      'Akun dibuat, proses masuk tidak tersimpan';

  @override
  String get authSocialStorageFailureBody =>
      'Akun Anda sudah siap, tetapi perangkat ini tidak dapat menyimpan proses masuk. Lanjutkan dengan Google atau masuk untuk menggunakannya.';

  @override
  String get authSocialSubmitUnconfirmed =>
      'Kami tidak dapat memastikan apakah pendaftaran selesai. Lanjutkan dengan Google atau masuk; jika akun belum dibuat, coba lagi.';

  @override
  String get authLinkInvalidTitle => 'Tautan tidak tersedia';

  @override
  String get authLinkInvalidBody =>
      'Permintaan tautan akun ini sudah tidak aktif. Mungkin sudah kedaluwarsa atau digunakan. Mulai lagi dengan Google untuk masuk.';

  @override
  String get authLinkDifferentAccountTitle => 'Akun Google berbeda';

  @override
  String get authLinkDifferentAccountBody =>
      'Akun Google yang digunakan di sini tidak cocok dengan akun saat tautan ini dimulai. Mulai lagi dan pilih akun yang Anda gunakan sebelumnya.';

  @override
  String get authGoogleSignInExpiredTitle => 'Proses masuk Google kedaluwarsa';

  @override
  String get authGoogleSignInExpiredBody =>
      'Google tidak lagi menerima proses masuk yang digunakan untuk tautan ini. Mulai lagi dengan Google untuk melanjutkan.';

  @override
  String get authAccountsLinkedTitle => 'Akun tertaut';

  @override
  String get authAccountsLinkedBody =>
      'Akun Google Anda sekarang tertaut, tetapi proses masuk belum selesai. Lanjutkan dengan Google lagi untuk masuk.';

  @override
  String get authGoogleAlreadyLinkedTitle => 'Akun Google sudah tertaut';

  @override
  String get authGoogleAlreadyLinkedBody =>
      'Akun Google ini sudah tertaut ke akun Stash-it. Lanjutkan dengan Google untuk masuk.';

  @override
  String get authLinkExistingAccount =>
      'Stash-it menemukan akun yang sudah ada untuk email ini. Tautkan akun Google yang baru saja Anda verifikasi ke akun tersebut?';

  @override
  String authLinkExistingAccountForEmail(String email) {
    return 'Stash-it menemukan akun yang sudah ada untuk $email. Tautkan akun Google yang baru saja Anda verifikasi ke akun tersebut?';
  }

  @override
  String authGoogleProfile(String name) {
    return 'Profil Google: $name';
  }

  @override
  String get authLinkUnavailableShort =>
      'Penautan akun untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authLinkCheckTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memeriksa tautan ini.';

  @override
  String get authLinkCheckGeneric =>
      'Kami tidak dapat memeriksa tautan ini. Coba lagi.';

  @override
  String get authLinkOutcomeUnconfirmed =>
      'Kami tidak dapat memastikan apakah penautan selesai. Lanjutkan dengan Google untuk masuk; jika belum tertaut, mulai lagi.';

  @override
  String get authLinkFailed =>
      'Kami tidak dapat menautkan akun ini. Coba lagi.';

  @override
  String get authGoogleNotConfigured =>
      'Proses masuk Google belum dikonfigurasi untuk versi ini.';

  @override
  String get authGoogleCouldNotStart =>
      'Proses masuk Google tidak dapat dimulai. Coba lagi.';

  @override
  String get authGoogleMissingToken =>
      'Google tidak mengembalikan token masuk. Coba lagi.';

  @override
  String get authGoogleBrowserFailed =>
      'Tidak dapat membuka browser untuk proses masuk Google. Coba lagi.';

  @override
  String get authGoogleSignInTimeout =>
      'Proses masuk Google habis waktu. Coba lagi.';

  @override
  String get authGoogleStateMismatch =>
      'Proses masuk Google tidak dapat diverifikasi. Coba lagi.';

  @override
  String get authGoogleCallbackError =>
      'Proses masuk Google tidak selesai. Coba lagi.';

  @override
  String get authCancelGoogleSignIn => 'Batalkan proses masuk Google';

  @override
  String get authGoogleSignInCancelled => 'Proses masuk Google dibatalkan.';

  @override
  String get authGoogleTokenExchangeFailed =>
      'Proses masuk Google tidak dapat diselesaikan setelah browser kembali. Coba lagi.';

  @override
  String get authGoogleInvalidToken =>
      'Google tidak dapat memverifikasi proses masuk itu. Coba lagi.';

  @override
  String get authGoogleRegistrationIdentityMismatch =>
      'Pendaftaran untuk email ini sedang berlangsung dengan akun lain. Coba lagi setelah kedaluwarsa.';

  @override
  String get authGoogleLinkSessionFailed =>
      'Akun Anda telah tertaut, tetapi proses masuk belum selesai. Lanjutkan dengan Google lagi.';

  @override
  String get authGoogleLinkIdentityMismatch =>
      'Akun Google itu tidak cocok dengan akun yang sedang ditautkan.';

  @override
  String get authGoogleLinkConfirmationInactive =>
      'Permintaan tautan akun ini sudah tidak aktif. Mulai lagi.';

  @override
  String get authGoogleAccountExists =>
      'Akun ini sudah ada. Lanjutkan dengan Google atau masuk.';

  @override
  String get authGoogleUnavailable =>
      'Proses masuk Google untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authGoogleServerFault =>
      'Kami tidak dapat memulai proses masuk Google. Coba lagi sebentar lagi.';

  @override
  String get authGoogleTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memulai proses masuk Google.';

  @override
  String get authGoogleUnreadable =>
      'Kami tidak dapat membaca balasan server, sehingga tidak dapat memulai proses masuk Google. Coba lagi.';

  @override
  String get authGoogleGenericFailure =>
      'Proses masuk Google tidak dapat diselesaikan. Coba lagi.';

  @override
  String get authResetRequestDescription =>
      'Masukkan alamat email Anda. Jika akun tersedia, kami akan mengirim PIN untuk mengonfirmasinya.';

  @override
  String get authResetSavedCheckFailure =>
      'Kami tidak dapat memeriksa reset kata sandi yang tersimpan. Anda dapat meminta yang baru.';

  @override
  String get authResetAlreadyCompletedNotice =>
      'Reset kata sandi ini sudah selesai. Masuk dengan kata sandi baru Anda, atau minta reset baru.';

  @override
  String get authResetPreviousInactive =>
      'Reset kata sandi Anda sebelumnya sudah tidak aktif. Minta yang baru.';

  @override
  String get authResetSavedCheckGeneric =>
      'Kami tidak dapat memeriksa reset kata sandi tersimpan Anda. Coba lagi.';

  @override
  String authResetSavedContinueMessage(String email) {
    return 'Reset kata sandi tersimpan untuk $email tersedia di perangkat ini. Lanjutkan, atau gunakan email lain.';
  }

  @override
  String get authResetAlreadyInProgress =>
      'Reset kata sandi sedang berlangsung. Coba lagi sebentar lagi.';

  @override
  String get authResetStartGeneric =>
      'Kami tidak dapat memulai reset kata sandi. Coba lagi.';

  @override
  String get authResetStartTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memulai reset kata sandi.';

  @override
  String get authResetStartUnreadable =>
      'Kami tidak dapat membaca balasan server, sehingga tidak dapat memulai reset kata sandi. Coba lagi.';

  @override
  String get authResetStartServerFault =>
      'Kami tidak dapat memulai reset kata sandi. Coba lagi sebentar lagi.';

  @override
  String get authResetUnavailableShort =>
      'Reset kata sandi untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authResetSavedCheckTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memeriksa reset kata sandi tersimpan Anda. Coba lagi.';

  @override
  String get authResetSavedCheckUnreadable =>
      'Kami tidak dapat memastikan apakah reset kata sandi tersimpan Anda masih aktif. Coba lagi.';

  @override
  String get authResetSavedCheckServerFault =>
      'Kami tidak dapat memeriksa reset kata sandi tersimpan Anda. Coba lagi sebentar lagi.';

  @override
  String get authResetContinueTitle => 'Lanjutkan reset kata sandi';

  @override
  String authResetInProgressFor(String email) {
    return 'Reset kata sandi sedang berlangsung untuk $email.';
  }

  @override
  String get authResetAlreadyVerifiedTitle => 'Reset sudah diverifikasi';

  @override
  String get authResetAlreadyVerifiedWaitingBody =>
      'Reset kata sandi ini sudah diverifikasi, tetapi perangkat ini tidak memiliki reset tersimpan yang dapat digunakan untuk email ini. Meminta PIN lain tidak dapat dilakukan. Reset akan kedaluwarsa dalam 15 menit; setelah itu Anda dapat meminta reset baru.';

  @override
  String get authResetNeutralBody =>
      'Jika akun tersedia untuk alamat tersebut, kami telah mengirim PIN reset kata sandi.';

  @override
  String authResetPinSentBody(String email) {
    return 'Kami mengirim PIN reset kata sandi ke $email.';
  }

  @override
  String get authResetAlreadyVerifiedBody =>
      'Langkah PIN reset ini sudah selesai. Jika perangkat ini memiliki reset tersimpan, lanjutkan dari layar reset kata sandi. Jika tidak, tunggu hingga 15 menit sampai kedaluwarsa lalu minta reset baru.';

  @override
  String get authResetNoLongerActiveTitle => 'Reset tidak lagi aktif';

  @override
  String get authResetNoLongerActiveBody =>
      'Reset kata sandi ini sudah tidak aktif. Minta yang baru untuk melanjutkan.';

  @override
  String get authResetNotAvailableTitle => 'Reset tidak tersedia';

  @override
  String get authResetNotAvailableBody =>
      'Kami tidak dapat menemukan reset kata sandi itu. Periksa alamatnya atau mulai lagi.';

  @override
  String get authResetVerifiedNotSavedTitle =>
      'Reset terverifikasi, tetapi tidak tersimpan';

  @override
  String get authResetVerifiedNotSavedBody =>
      'PIN Anda sudah diverifikasi, tetapi perangkat ini tidak dapat menyimpan reset dengan aman. Reset tidak dapat dilanjutkan di sini. Minta reset baru setelah reset ini kedaluwarsa, yang memerlukan waktu hingga 15 menit.';

  @override
  String get authResetSavedCheckLocalFailure =>
      'Kami tidak dapat memeriksa reset tersimpan di perangkat ini. Coba lagi.';

  @override
  String authResetReplacementUnknownIncoming(String savedEmail) {
    return 'Reset kata sandi tersimpan untuk $savedEmail ada di perangkat ini. Jika PIN ini terverifikasi, reset tersebut dapat tergantikan; reset tersimpan untuk $savedEmail mungkin tidak lagi tersedia di perangkat ini. Ini tidak membatalkannya di server.';
  }

  @override
  String authResetReplacementKnownIncoming(String incoming, String savedEmail) {
    return 'Reset kata sandi tersimpan untuk $savedEmail ada di perangkat ini. Jika PIN ini terverifikasi untuk $incoming, PIN tersebut akan menggantikannya; reset tersimpan untuk $savedEmail tidak akan lagi tersedia di perangkat ini. Ini tidak membatalkannya di server.';
  }

  @override
  String authResetPinSentToEmail(String email) {
    return 'Kami mengirim PIN ke $email. Masukkan di bawah untuk memilih kata sandi baru.';
  }

  @override
  String authResetPinSentToEmailIssued(String email) {
    return 'Kami mengirim PIN ke $email. Jika Anda sudah memilikinya, masukkan di bawah untuk memilih kata sandi baru.';
  }

  @override
  String get authResetPinSentGeneric =>
      'Kami mengirim PIN ke alamat email Anda. Masukkan di bawah untuk memilih kata sandi baru.';

  @override
  String get authResetPinSentGenericIssued =>
      'Kami mengirim PIN ke alamat email Anda. Jika Anda sudah memilikinya, masukkan di bawah untuk memilih kata sandi baru.';

  @override
  String get authResetResendUnavailable =>
      'Pengiriman PIN untuk sementara tidak tersedia. Coba lagi sebentar lagi.';

  @override
  String get authResetResendTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat meminta PIN baru.';

  @override
  String get authResetResendGeneric =>
      'Kami tidak dapat meminta PIN baru. Coba lagi.';

  @override
  String get authResetLoadTransport =>
      'Tidak ada koneksi ke server. Kami tidak dapat memeriksa reset ini. Coba lagi.';

  @override
  String get authResetLoadServerFault =>
      'Kami tidak dapat memeriksa reset ini. Coba lagi sebentar lagi.';

  @override
  String get authResetLoadGeneric =>
      'Kami tidak dapat memeriksa reset ini. Coba lagi.';

  @override
  String get authResetStorageReadFailure =>
      'Kami tidak dapat membaca reset kata sandi tersimpan dari perangkat ini. Coba lagi.';

  @override
  String get authResetCompletedTitle => 'Reset kata sandi selesai';

  @override
  String get authResetCompletedBody =>
      'Reset kata sandi ini sudah selesai. Masuk dengan kata sandi baru Anda.';

  @override
  String get authNoResetInProgressTitle =>
      'Tidak ada reset yang sedang berlangsung';

  @override
  String get authNoResetInProgressBody =>
      'Mulai reset kata sandi dari halaman masuk untuk memilih kata sandi baru.';

  @override
  String authChooseNewPasswordForEmail(String email) {
    return 'Pilih kata sandi baru untuk $email.';
  }

  @override
  String authSetPasswordForEmail(String email) {
    return 'Atur kata sandi untuk $email.';
  }

  @override
  String authResetSubmitRateLimitedWithWait(int seconds) {
    return 'Kami tidak dapat mereset kata sandi Anda saat ini. Coba lagi dalam $seconds detik.';
  }

  @override
  String get authResetSubmitRateLimitedNoWait =>
      'Kami tidak dapat mereset kata sandi Anda saat ini. Coba lagi sebentar lagi.';

  @override
  String get authResetOutcomeUnconfirmed =>
      'Kami tidak dapat memastikan apakah reset kata sandi selesai. Coba masuk dengan kata sandi baru Anda.';

  @override
  String get authResetSubmitGeneric =>
      'Kami tidak dapat mereset kata sandi Anda. Coba lagi.';
}
