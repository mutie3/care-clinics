import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900])
        : ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.white,
          );
  }

  ThemeProvider() {
    _loadThemePreference(); // تحميل حالة الثيم عند الإنشاء
  }

  void toggleTheme(bool isEnabled) {
    _isDarkMode = isEnabled;
    _saveThemePreference(isEnabled); // حفظ حالة الثيم
    notifyListeners(); // إعلام المستمعين بالتغيير
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // الافتراضي: false
    notifyListeners(); // إعلام المستمعين بعد التحميل
  }

  Future<void> _saveThemePreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isEnabled);
  }
}
