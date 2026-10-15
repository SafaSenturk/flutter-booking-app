// Firebase configuration for the Glow Booking project (Android).
//
// These values identify the Firebase project; they are not secrets. Access to
// data is controlled by `firestore.rules`, and the API key is restricted to
// this app's package name and signing certificates.
import 'package:firebase_core/firebase_core.dart';

abstract final class DefaultFirebaseOptions {
  static const currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyAOXJ5qwZ6XNp-N1DdZVQEzDCOH06gY4LU',
    appId: '1:439372057681:android:4ab09b7bd015e89265fc70',
    messagingSenderId: '439372057681',
    projectId: 'glow-booking-portfolio',
    storageBucket: 'glow-booking-portfolio.firebasestorage.app',
  );

  /// OAuth "web" client id, required by Google Sign-In on Android.
  static const googleServerClientId =
      '439372057681-sdevqgg9dkojue71vknqvki6t42m05hv.apps.googleusercontent.com';
}
