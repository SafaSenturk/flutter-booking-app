// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Glow Studio';

  @override
  String get tagline => 'Book your beauty moment in seconds';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String resetSent(String email) {
    return 'We sent a reset link to $email.';
  }

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'or';

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordLength => 'At least 6 characters';

  @override
  String get errorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get errorEmailInUse => 'An account with this email already exists.';

  @override
  String get errorWeakPassword => 'Choose a stronger password.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorLoad => 'Couldn\'t load this right now.';

  @override
  String get retry => 'Retry';

  @override
  String get tabBook => 'Book';

  @override
  String get tabAppointments => 'Appointments';

  @override
  String get tabSalon => 'Salon';

  @override
  String get tabProfile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeTitle => 'What would you\nlike today?';

  @override
  String get salonAddress => 'Bağdat Cad. 214, Kadıköy · İstanbul';

  @override
  String get openHours => 'Mon–Sat · 09:00–19:00';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryHair => 'Hair';

  @override
  String get categoryNails => 'Nails';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryMakeup => 'Makeup';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get book => 'Book';

  @override
  String get ourTeam => 'Our team';

  @override
  String get services => 'Services';

  @override
  String get chooseSpecialist => 'Choose your specialist';

  @override
  String get anySpecialist => 'Any';

  @override
  String get anySpecialistHint => 'First available';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get availableTimes => 'Available times';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get closedDay => 'We\'re closed on this day.';

  @override
  String get fullyBooked => 'Fully booked — try another day or specialist.';

  @override
  String get noteHint => 'Anything we should know? (optional)';

  @override
  String get requestBooking => 'Request booking';

  @override
  String get slotTaken =>
      'Someone just booked that time. Please pick another one.';

  @override
  String get bookingFailed =>
      'We couldn\'t save your booking. Please try again.';

  @override
  String get bookingSentTitle => 'Request sent!';

  @override
  String get bookingSentBody =>
      'The salon will confirm your appointment shortly. You\'ll get a notification.';

  @override
  String get viewAppointments => 'View my appointments';

  @override
  String get backHome => 'Back to services';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get noUpcomingTitle => 'No upcoming appointments';

  @override
  String get noUpcomingBody =>
      'Treat yourself — book your next visit in a few taps.';

  @override
  String get noPast => 'Your past visits will appear here.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String withStaff(String name) {
    return 'with $name';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelTitle => 'Cancel this appointment?';

  @override
  String get cancelBody => 'The time will be released for other customers.';

  @override
  String get keep => 'Keep it';

  @override
  String get cancelTooLate => 'Cancellation is possible up to 2 hours before.';

  @override
  String get salonPanel => 'Salon panel';

  @override
  String get demoBanner =>
      'Demo owner mode — you are managing your own bookings.';

  @override
  String get statPending => 'Requests';

  @override
  String get statToday => 'Booked';

  @override
  String get statRevenue => 'Revenue';

  @override
  String get requests => 'Requests';

  @override
  String get schedule => 'Schedule';

  @override
  String get noRequests => 'No requests waiting. 🎉';

  @override
  String get noBookingsDay => 'No bookings on this day.';

  @override
  String get approve => 'Approve';

  @override
  String get decline => 'Decline';

  @override
  String get markDone => 'Mark done';

  @override
  String get notifConfirmedTitle => 'Appointment confirmed ✨';

  @override
  String notifConfirmedBody(String service, String date) {
    return '$service on $date is confirmed. See you soon!';
  }

  @override
  String get notifDeclinedTitle => 'Appointment declined';

  @override
  String notifDeclinedBody(String service, String date) {
    return '$service on $date couldn\'t be confirmed. Please pick another time.';
  }

  @override
  String get profile => 'Profile';

  @override
  String get phone => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get language => 'Language';

  @override
  String get demoOwnerTitle => 'Try the salon panel';

  @override
  String get demoOwnerBody =>
      'Approve or decline your own bookings as if you were the salon owner. Other customers\' data is never visible.';

  @override
  String get signOut => 'Sign out';

  @override
  String get adminBadge => 'Salon owner';
}
