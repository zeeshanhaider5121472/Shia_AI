import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontScale = 1.0;
  String _fontFamily = 'Plus Jakarta Sans';
  String _arabicFontFamily = 'Amiri';

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  String get fontFamily => _fontFamily;
  String get arabicFontFamily => _arabicFontFamily;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        (prefs.getBool('isDark') ?? true) ? ThemeMode.dark : ThemeMode.light;
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Plus Jakarta Sans';
    _arabicFontFamily = prefs.getString('arabicFont') ?? 'Amiri';
    _apply();
  }

  void toggleTheme(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    _apply();
    SharedPreferences.getInstance().then((p) => p.setBool('isDark', dark));
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    _apply();
    SharedPreferences.getInstance()
        .then((p) => p.setDouble('fontScale', scale));
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    _apply();
    SharedPreferences.getInstance()
        .then((p) => p.setString('fontFamily', family));
    notifyListeners();
  }

  void setArabicFontFamily(String family) {
    _arabicFontFamily = family;
    _apply();
    SharedPreferences.getInstance()
        .then((p) => p.setString('arabicFont', family));
    notifyListeners();
  }

  void _apply() {
    AppColors.isDark = isDark;
    AppStyles.fontScale = _fontScale;
    AppStyles.fontFamily = _fontFamily;
    AppStyles.arabicFontFamily = _arabicFontFamily;
  }
}
