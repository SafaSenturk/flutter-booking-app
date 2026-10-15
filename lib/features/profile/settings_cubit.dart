import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language; null follows the device.
class SettingsCubit extends Cubit<Locale?> {
  SettingsCubit(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Locale? _load(SharedPreferences p) {
    final code = p.getString('locale');
    return code == null ? null : Locale(code);
  }

  void setLocale(Locale locale) {
    emit(locale);
    _prefs.setString('locale', locale.languageCode);
  }
}
