import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/home_page.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGuestLoginPressed;

  const LoginButtons({
    Key? key,
    required this.onLoginPressed,
    required this.onGuestLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? Colors.grey
                      : AppColors.scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onGuestLoginPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Guest Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
