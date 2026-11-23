import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _supportedLocales = ['en', 'tr', 'es', 'de'];

  /// Kayıtlı tercih yoksa cihaz dili (destekleniyorsa), değilse İngilizce.
  static Locale deviceDefault([Locale? device]) {
    final code = (device ?? PlatformDispatcher.instance.locale).languageCode;
    return Locale(_supportedLocales.contains(code) ? code : 'en');
  }

  Locale _locale = deviceDefault();

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');
    if (code != null && _supportedLocales.contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) {
    if (!_supportedLocales.contains(locale.languageCode)) return;
    _locale = locale;
    _saveLocale();
    notifyListeners();
  }

  Future<void> _saveLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
  }

  /// Kullanıcı tercihini siler; uygulama yeniden cihaz dilini izler.
  Future<void> clearLocale() async {
    _locale = deviceDefault();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    notifyListeners();
  }
}
