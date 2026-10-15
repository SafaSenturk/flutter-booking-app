import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

extension UiX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
  String get lang => Localizations.localeOf(this).languageCode;

  String money(int lira) => NumberFormat.currency(locale: lang, symbol: '₺', decimalDigits: 0).format(lira);
  String time(DateTime t) => DateFormat.Hm(lang).format(t);
  String weekdayShort(DateTime t) => DateFormat.E(lang).format(t);
  String longDate(DateTime t) => DateFormat.MMMMEEEEd(lang).format(t);
  String shortDate(DateTime t) => DateFormat.MMMd(lang).format(t);
  String monthShort(DateTime t) => DateFormat.MMM(lang).format(t).toUpperCase();

  String category(String c) => switch (c) {
        'hair' => l.categoryHair,
        'nails' => l.categoryNails,
        'skin' => l.categorySkin,
        'makeup' => l.categoryMakeup,
        _ => c,
      };

  String status(AppointmentStatus s) => switch (s) {
        AppointmentStatus.pending => l.statusPending,
        AppointmentStatus.confirmed => l.statusConfirmed,
        AppointmentStatus.declined => l.statusDeclined,
        AppointmentStatus.cancelled => l.statusCancelled,
        AppointmentStatus.completed => l.statusCompleted,
      };

  String authError(Object e) => switch (e is AuthFailure ? e.kind : AuthErrorKind.unknown) {
        AuthErrorKind.invalidCredentials => l.errorInvalidCredentials,
        AuthErrorKind.emailInUse => l.errorEmailInUse,
        AuthErrorKind.weakPassword => l.errorWeakPassword,
        AuthErrorKind.network => l.errorNetwork,
        _ => l.errorUnknown,
      };

  void toast(String message, {bool error = false}) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Theme.of(this).colorScheme.error : null,
    ));
}

IconData serviceIcon(String name) => switch (name) {
      'content_cut' => Icons.content_cut_rounded,
      'air' => Icons.air_rounded,
      'palette' => Icons.palette_rounded,
      'back_hand' => Icons.back_hand_rounded,
      'spa' => Icons.spa_rounded,
      'face' => Icons.face_retouching_natural_rounded,
      'brush' => Icons.brush_rounded,
      _ => Icons.auto_awesome_rounded,
    };

(Color, Color) statusColors(AppointmentStatus s) => switch (s) {
      AppointmentStatus.pending => (const Color(0xFFFFF1D6), const Color(0xFF9A6A00)),
      AppointmentStatus.confirmed => (Glow.sageSoft, Glow.sage),
      AppointmentStatus.completed => (const Color(0xFFE7E3F0), const Color(0xFF5E5470)),
      AppointmentStatus.declined || AppointmentStatus.cancelled => (const Color(0xFFF7E1E0), const Color(0xFFB33A34)),
    };

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        context.status(status),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class StaffAvatar extends StatelessWidget {
  const StaffAvatar({super.key, required this.staff, this.size = 56});

  final Staff staff;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: Glow.avatarColors[staff.colorIndex % Glow.avatarColors.length],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          staff.initials,
          style: TextStyle(fontFamily: Glow.serif, color: Colors.white, fontSize: size * .38),
        ),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.title, this.body = '', this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(color: Glow.roseSoft, shape: BoxShape.circle),
                child: Icon(icon, color: Glow.rose, size: 40),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: Glow.serif, fontSize: 24)),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Glow.inkSoft, height: 1.45)),
              ],
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      );
}

/// Local notifications for booking status changes.
class Notifier {
  Notifier._();

  static final instance = Notifier._();
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
    );
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'bookings',
      'Bookings',
      description: 'Appointment confirmations',
      importance: Importance.high,
    ));
  }

  Future<void> requestPermission() async => _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  Future<void> show(String id, String title, String body) => _plugin.show(
        id: id.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'bookings',
            'Bookings',
            importance: Importance.high,
            priority: Priority.high,
            color: Glow.rose,
          ),
        ),
      );
}
