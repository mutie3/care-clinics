import 'package:care_clinic/constants/colors_page.dart';
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
  _RememberMeAndForgotPasswordRowState createState() =>
      _RememberMeAndForgotPasswordRowState();
}

class _RememberMeAndForgotPasswordRowState
    extends State<RememberMeAndForgotPasswordRow> {
  late bool rememberMe;

  @override
  void initState() {
    super.initState();
    rememberMe =
        widget.rememberMe; // Initialize with the passed rememberMe value
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
                    widget.onRememberMeChanged(
                        rememberMe); // Notify the parent widget of the change
                    _saveRememberMe(); // Save the value whenever it's changed
                  },
                  activeColor: themeProvider.isDarkMode
                      ? AppColors.textBox
                      : AppColors.primaryColor,
                  checkColor: AppColors.scaffoldBackgroundColor,
                ),
                Text(
                  '62'.tr,
                  style: const TextStyle(color: AppColors.textBox),
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
                  color: themeProvider.isDarkMode
                      ? AppColors.textBox
                      : AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
