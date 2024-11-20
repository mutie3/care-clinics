import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/forgot_password_page.dart';

class RememberMeAndForgotPasswordRow extends StatefulWidget {
  const RememberMeAndForgotPasswordRow({super.key});

  @override
  _RememberMeAndForgotPasswordRowState createState() =>
      _RememberMeAndForgotPasswordRowState();
}

class _RememberMeAndForgotPasswordRowState
    extends State<RememberMeAndForgotPasswordRow> {
  bool rememberMe = false;

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
                  },
                  activeColor: themeProvider.isDarkMode
                      ? AppColors.textBox
                      : AppColors.primaryColor,
                  checkColor: AppColors.scaffoldBackgroundColor,
                ),
                const Text(
                  'Remember Me?',
                  style: TextStyle(color: AppColors.textBox),
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
                'Forgot Password?',
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
