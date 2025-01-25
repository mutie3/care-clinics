import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../screens/forgot_password_page.dart';

class RememberMeAndForgotPasswordRow extends StatefulWidget {
  final bool rememberMe; // Take rememberMe as a parameter
  final ValueChanged<bool?> onRememberMeChanged; // Callback for changes

  const RememberMeAndForgotPasswordRow({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  @override
  RememberMeAndForgotPasswordRowState createState() =>
      RememberMeAndForgotPasswordRowState();
}

class RememberMeAndForgotPasswordRowState
    extends State<RememberMeAndForgotPasswordRow> {
  late bool rememberMe;

  @override
  void initState() {
    super.initState();

    rememberMe = widget.rememberMe || false;

    _initializeRememberMe();
  }

  Future<void> _initializeRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('rememberMe')) {
      await prefs.setBool('rememberMe', true);
    }
  }

  // Function to save the rememberMe value to SharedPreferences
  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                    widget.onRememberMeChanged(rememberMe);
                  },
                  activeColor: isDarkMode
                      ? Colors.blueAccent
                      : Colors.blue, // لون Checkbox عند التفعيل
                  checkColor: isDarkMode
                      ? Colors.white
                      : Colors.black87, // لون الإشارة عند التفعيل
                ),
                Text(
                  '62'.tr,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87, // Text color based on mode
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage()),
                );
              },
              child: Text(
                '63'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: isDarkMode
                      ? Colors.white
                      : Colors.blue, // Text button color
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
