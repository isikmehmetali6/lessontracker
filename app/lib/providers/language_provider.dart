import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  static const _supportedLocales = ['en', 'tr', 'es', 'de'];

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

  void clearLocale() {
    _locale = const Locale('en');
    _saveLocale();
    notifyListeners();
  }
}
