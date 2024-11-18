import 'package:flutter/material.dart';

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

  void toggleTheme(bool isEnabled) {
    _isDarkMode = isEnabled;
    notifyListeners(); // إعلام جميع المستمعين بتغيير الحالة
  }
}
