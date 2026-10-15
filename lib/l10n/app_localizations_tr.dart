// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Glow Studio';

  @override
  String get tagline => 'Güzellik randevunu saniyeler içinde al';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Hesap oluştur';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String resetSent(String email) {
    return '$email adresine sıfırlama bağlantısı gönderdik.';
  }

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get or => 'veya';

  @override
  String get required => 'Zorunlu alan';

  @override
  String get invalidEmail => 'Geçerli bir e-posta gir';

  @override
  String get passwordLength => 'En az 6 karakter';

  @override
  String get errorInvalidCredentials => 'E-posta ya da şifre hatalı.';

  @override
  String get errorEmailInUse => 'Bu e-postayla zaten bir hesap var.';

  @override
  String get errorWeakPassword => 'Daha güçlü bir şifre seç.';

  @override
  String get errorNetwork => 'İnternet bağlantısı yok.';

  @override
  String get errorUnknown => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String get errorLoad => 'Şu an yüklenemedi.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get tabBook => 'Randevu al';

  @override
  String get tabAppointments => 'Randevularım';

  @override
  String get tabSalon => 'Salon';

  @override
  String get tabProfile => 'Profil';

  @override
  String greeting(String name) {
    return 'Merhaba $name';
  }

  @override
  String get homeTitle => 'Bugün ne\nyaptırmak istersin?';

  @override
  String get salonAddress => 'Bağdat Cad. 214, Kadıköy · İstanbul';

  @override
  String get openHours => 'Pzt–Cmt · 09:00–19:00';

  @override
  String get categoryAll => 'Tümü';

  @override
  String get categoryHair => 'Saç';

  @override
  String get categoryNails => 'Tırnak';

  @override
  String get categorySkin => 'Cilt';

  @override
  String get categoryMakeup => 'Makyaj';

  @override
  String minutes(int count) {
    return '$count dk';
  }

  @override
  String get book => 'Seç';

  @override
  String get ourTeam => 'Ekibimiz';

  @override
  String get services => 'Hizmetler';

  @override
  String get chooseSpecialist => 'Uzmanını seç';

  @override
  String get anySpecialist => 'Fark etmez';

  @override
  String get anySpecialistHint => 'İlk müsait olan';

  @override
  String get pickDate => 'Tarih seç';

  @override
  String get availableTimes => 'Müsait saatler';

  @override
  String get morning => 'Sabah';

  @override
  String get afternoon => 'Öğleden sonra';

  @override
  String get evening => 'Akşam';

  @override
  String get closedDay => 'Bu gün kapalıyız.';

  @override
  String get fullyBooked => 'Bu gün dolu — başka bir gün ya da uzman dene.';

  @override
  String get noteHint => 'Bilmemiz gereken bir şey var mı? (isteğe bağlı)';

  @override
  String get requestBooking => 'Randevu talep et';

  @override
  String get slotTaken => 'Bu saat az önce alındı. Lütfen başka bir saat seç.';

  @override
  String get bookingFailed => 'Randevun kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get bookingSentTitle => 'Talebin alındı!';

  @override
  String get bookingSentBody =>
      'Salon randevunu kısa süre içinde onaylayacak. Bildirim alacaksın.';

  @override
  String get viewAppointments => 'Randevularımı gör';

  @override
  String get backHome => 'Hizmetlere dön';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get past => 'Geçmiş';

  @override
  String get noUpcomingTitle => 'Yaklaşan randevun yok';

  @override
  String get noUpcomingBody =>
      'Kendini şımart — bir sonraki ziyaretini birkaç dokunuşla planla.';

  @override
  String get noPast => 'Geçmiş ziyaretlerin burada görünecek.';

  @override
  String get statusPending => 'Onay bekliyor';

  @override
  String get statusConfirmed => 'Onaylandı';

  @override
  String get statusDeclined => 'Reddedildi';

  @override
  String get statusCancelled => 'İptal edildi';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String withStaff(String name) {
    return '$name ile';
  }

  @override
  String get cancel => 'Vazgeç';

  @override
  String get cancelBooking => 'Randevuyu iptal et';

  @override
  String get cancelTitle => 'Randevu iptal edilsin mi?';

  @override
  String get cancelBody => 'Bu saat diğer müşterilere açılacak.';

  @override
  String get keep => 'Kalsın';

  @override
  String get cancelTooLate =>
      'İptal, randevudan 2 saat öncesine kadar yapılabilir.';

  @override
  String get salonPanel => 'Salon paneli';

  @override
  String get demoBanner =>
      'Demo salon modu — kendi randevularını yönetiyorsun.';

  @override
  String get statPending => 'Talep';

  @override
  String get statToday => 'Randevu';

  @override
  String get statRevenue => 'Ciro';

  @override
  String get requests => 'Talepler';

  @override
  String get schedule => 'Takvim';

  @override
  String get noRequests => 'Bekleyen talep yok. 🎉';

  @override
  String get noBookingsDay => 'Bu günde randevu yok.';

  @override
  String get approve => 'Onayla';

  @override
  String get decline => 'Reddet';

  @override
  String get markDone => 'Tamamlandı';

  @override
  String get notifConfirmedTitle => 'Randevun onaylandı ✨';

  @override
  String notifConfirmedBody(String service, String date) {
    return '$date tarihli $service randevun onaylandı. Görüşmek üzere!';
  }

  @override
  String get notifDeclinedTitle => 'Randevun reddedildi';

  @override
  String notifDeclinedBody(String service, String date) {
    return '$date tarihli $service randevun onaylanamadı. Lütfen başka bir saat seç.';
  }

  @override
  String get profile => 'Profil';

  @override
  String get phone => 'Telefon';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get language => 'Dil';

  @override
  String get demoOwnerTitle => 'Salon panelini dene';

  @override
  String get demoOwnerBody =>
      'Kendi randevularını salon sahibiymiş gibi onayla ya da reddet. Diğer müşterilerin bilgileri asla görünmez.';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get adminBadge => 'Salon sahibi';
}
