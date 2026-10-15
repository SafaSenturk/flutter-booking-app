import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Glow Studio'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Book your beauty moment in seconds'**
  String get tagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}.'**
  String resetSent(String email);

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordLength;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this right now.'**
  String get errorLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tabBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get tabBook;

  /// No description provided for @tabAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get tabAppointments;

  /// No description provided for @tabSalon.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get tabSalon;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greeting(String name);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you\nlike today?'**
  String get homeTitle;

  /// No description provided for @salonAddress.
  ///
  /// In en, this message translates to:
  /// **'Bağdat Cad. 214, Kadıköy · İstanbul'**
  String get salonAddress;

  /// No description provided for @openHours.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat · 09:00–19:00'**
  String get openHours;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get categoryHair;

  /// No description provided for @categoryNails.
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get categoryNails;

  /// No description provided for @categorySkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get categorySkin;

  /// No description provided for @categoryMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get categoryMakeup;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @ourTeam.
  ///
  /// In en, this message translates to:
  /// **'Our team'**
  String get ourTeam;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @chooseSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Choose your specialist'**
  String get chooseSpecialist;

  /// No description provided for @anySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anySpecialist;

  /// No description provided for @anySpecialistHint.
  ///
  /// In en, this message translates to:
  /// **'First available'**
  String get anySpecialistHint;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @availableTimes.
  ///
  /// In en, this message translates to:
  /// **'Available times'**
  String get availableTimes;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @closedDay.
  ///
  /// In en, this message translates to:
  /// **'We\'re closed on this day.'**
  String get closedDay;

  /// No description provided for @fullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Fully booked — try another day or specialist.'**
  String get fullyBooked;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything we should know? (optional)'**
  String get noteHint;

  /// No description provided for @requestBooking.
  ///
  /// In en, this message translates to:
  /// **'Request booking'**
  String get requestBooking;

  /// No description provided for @slotTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone just booked that time. Please pick another one.'**
  String get slotTaken;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your booking. Please try again.'**
  String get bookingFailed;

  /// No description provided for @bookingSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent!'**
  String get bookingSentTitle;

  /// No description provided for @bookingSentBody.
  ///
  /// In en, this message translates to:
  /// **'The salon will confirm your appointment shortly. You\'ll get a notification.'**
  String get bookingSentBody;

  /// No description provided for @viewAppointments.
  ///
  /// In en, this message translates to:
  /// **'View my appointments'**
  String get viewAppointments;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to services'**
  String get backHome;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingTitle;

  /// No description provided for @noUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Treat yourself — book your next visit in a few taps.'**
  String get noUpcomingBody;

  /// No description provided for @noPast.
  ///
  /// In en, this message translates to:
  /// **'Your past visits will appear here.'**
  String get noPast;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @withStaff.
  ///
  /// In en, this message translates to:
  /// **'with {name}'**
  String withStaff(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get cancelTitle;

  /// No description provided for @cancelBody.
  ///
  /// In en, this message translates to:
  /// **'The time will be released for other customers.'**
  String get cancelBody;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keep;

  /// No description provided for @cancelTooLate.
  ///
  /// In en, this message translates to:
  /// **'Cancellation is possible up to 2 hours before.'**
  String get cancelTooLate;

  /// No description provided for @salonPanel.
  ///
  /// In en, this message translates to:
  /// **'Salon panel'**
  String get salonPanel;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo owner mode — you are managing your own bookings.'**
  String get demoBanner;

  /// No description provided for @statPending.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get statPending;

  /// No description provided for @statToday.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statToday;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get statRevenue;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests waiting. 🎉'**
  String get noRequests;

  /// No description provided for @noBookingsDay.
  ///
  /// In en, this message translates to:
  /// **'No bookings on this day.'**
  String get noBookingsDay;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @notifConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment confirmed ✨'**
  String get notifConfirmedTitle;

  /// No description provided for @notifConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'{service} on {date} is confirmed. See you soon!'**
  String notifConfirmedBody(String service, String date);

  /// No description provided for @notifDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment declined'**
  String get notifDeclinedTitle;

  /// No description provided for @notifDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'{service} on {date} couldn\'t be confirmed. Please pick another time.'**
  String notifDeclinedBody(String service, String date);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @demoOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Try the salon panel'**
  String get demoOwnerTitle;

  /// No description provided for @demoOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'Approve or decline your own bookings as if you were the salon owner. Other customers\' data is never visible.'**
  String get demoOwnerBody;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @adminBadge.
  ///
  /// In en, this message translates to:
  /// **'Salon owner'**
  String get adminBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
