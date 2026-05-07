import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Color scheme
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryTealDark = Color(0xFF004D40);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFF5E6CC);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color lightBg = Color(0xFFF5F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentGold,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
      ),
    );
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryTeal,
        secondary: accentGold,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
      ),
      iconTheme: const IconThemeData(color: Colors.black54),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
    );
  }
}
