import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/availability.dart';
import '../firebase_options.dart';
import 'models.dart';

enum AuthErrorKind { invalidCredentials, emailInUse, weakPassword, invalidEmail, network, cancelled, unknown }

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthErrorKind kind;

  factory AuthFailure.fromCode(String code) => AuthFailure(switch (code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => AuthErrorKind.invalidCredentials,
        'email-already-in-use' || 'account-exists-with-different-credential' => AuthErrorKind.emailInUse,
        'weak-password' => AuthErrorKind.weakPassword,
        'invalid-email' => AuthErrorKind.invalidEmail,
        'network-request-failed' => AuthErrorKind.network,
        _ => AuthErrorKind.unknown,
      });
}

class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  bool _googleReady = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<AppUser?> watchProfile(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((d) => d.exists ? AppUser.fromDoc(d) : null);

  Future<void> signIn(String email, String password) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> signUp({required String name, required String email, required String password}) => _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await _ensureProfile(cred.user!, name.trim());
      });

  Future<void> signInWithGoogle() => _guard(() async {
        final google = GoogleSignIn.instance;
        if (!_googleReady) {
          await google.initialize(serverClientId: DefaultFirebaseOptions.googleServerClientId);
          _googleReady = true;
        }
        final GoogleSignInAccount account;
        try {
          account = await google.authenticate();
        } on GoogleSignInException catch (e) {
          throw AuthFailure(
              e.code == GoogleSignInExceptionCode.canceled ? AuthErrorKind.cancelled : AuthErrorKind.unknown);
        }
        final result = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: account.authentication.idToken),
        );
        await _ensureProfile(result.user!, account.displayName ?? '');
      });

  Future<void> sendPasswordReset(String email) => _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> signOut() async {
    if (_googleReady) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<void> updateProfile(String uid, {String? name, String? phone, bool? demoOwner}) =>
      _db.collection('users').doc(uid).update({
        'name': ?name,
        'phone': ?phone,
        'demoOwner': ?demoOwner,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> _ensureProfile(User user, String name) async {
    final ref = _db.collection('users').doc(user.uid);
    if ((await ref.get()).exists) return;
    await ref.set({
      'name': name.isNotEmpty ? name : user.email!.split('@').first,
      'email': user.email,
      'phone': '',
      'role': 'customer',
      'demoOwner': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }
}

class CatalogRepository {
  CatalogRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<Service>> watchServices() =>
      _db.collection('services').orderBy('order').snapshots().map((s) => s.docs.map(Service.fromDoc).toList());

  Stream<List<Staff>> watchStaff() =>
      _db.collection('staff').orderBy('order').snapshots().map((s) => s.docs.map(Staff.fromDoc).toList());
}

class SlotTakenException implements Exception {
  const SlotTakenException();
}

class BookingRepository {
  BookingRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _appointments => _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _slots => _db.collection('slots');

  /// staffId → booked time keys ("0930") on [day].
  Stream<Map<String, Set<String>>> watchTakenSlots(DateTime day) => _slots
      .where('day', isEqualTo: Availability.dayKey(day))
      .snapshots()
      .map((s) {
        final taken = <String, Set<String>>{};
        for (final d in s.docs) {
          taken.putIfAbsent(d['staffId'] as String, () => {}).add(d['time'] as String);
        }
        return taken;
      });

  Stream<List<Appointment>> watchMine(String uid) => _appointments
      .where('uid', isEqualTo: uid)
      .orderBy('start', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Appointment.fromDoc).toList());

  /// Owner view: every booking that starts on [day].
  Stream<List<Appointment>> watchDay(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    return _appointments
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('start', isLessThan: Timestamp.fromDate(from.add(const Duration(days: 1))))
        .orderBy('start')
        .snapshots()
        .map((s) => s.docs.map(Appointment.fromDoc).toList());
  }

  /// Owner view: requests waiting for an answer.
  Stream<List<Appointment>> watchPending() => _appointments
      .where('status', isEqualTo: 'pending')
      .orderBy('start')
      .snapshots()
      .map((s) => s.docs.map(Appointment.fromDoc).toList());

  /// Books atomically: fails with [SlotTakenException] if someone else took
  /// any of the slots in the meantime.
  Future<String> book({
    required AppUser user,
    required Service service,
    required Staff staff,
    required DateTime start,
    String note = '',
  }) async {
    final slotIds = Availability.slotIds(staffId: staff.id, start: start, durationMin: service.durationMin);
    final appointment = _appointments.doc();
    await _db.runTransaction((tx) async {
      for (final id in slotIds) {
        if ((await tx.get(_slots.doc(id))).exists) throw const SlotTakenException();
      }
      tx.set(appointment, {
        'uid': user.uid,
        'customerName': user.name,
        'serviceId': service.id,
        'serviceNameEn': service.nameEn,
        'serviceNameTr': service.nameTr,
        'staffId': staff.id,
        'staffName': staff.name,
        'start': Timestamp.fromDate(start),
        'durationMin': service.durationMin,
        'price': service.price,
        'status': 'pending',
        'note': note.trim(),
        'slotIds': slotIds,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (final id in slotIds) {
        final parts = id.split('_');
        tx.set(_slots.doc(id), {
          'staffId': staff.id,
          'day': parts[parts.length - 2],
          'time': parts.last,
          'uid': user.uid,
          'appointmentId': appointment.id,
        });
      }
    });
    return appointment.id;
  }

  /// Changes the status; cancelling or declining also frees the time slots.
  Future<void> setStatus(Appointment a, AppointmentStatus status, {String note = ''}) {
    final batch = _db.batch()
      ..update(_appointments.doc(a.id), {
        'status': status.name,
        'statusNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (status == AppointmentStatus.cancelled || status == AppointmentStatus.declined) {
      for (final id in a.slotIds) {
        batch.delete(_slots.doc(id));
      }
    }
    return batch.commit();
  }
}
