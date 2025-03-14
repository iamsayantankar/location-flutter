import 'package:flutter/material.dart';

/// ThemeManager class to handle theme switching in the app.
/// Uses ChangeNotifier to notify listeners when the theme changes.
class ThemeManager with ChangeNotifier {
  // Private variable to store the current theme mode (default is light mode)
  ThemeMode _themeMode = ThemeMode.light;

  // Getter to retrieve the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Toggles between light and dark themes based on the `isDark` flag.
  /// - `isDark = true` → Sets theme to Dark Mode.
  /// - `isDark = false` → Sets theme to Light Mode.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Notify all listeners about the theme change
    notifyListeners();
  }
}
