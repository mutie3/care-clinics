import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGuestLoginPressed;

  const LoginButtons({
    super.key,
    required this.onLoginPressed,
    required this.onGuestLoginPressed,
  });

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
              child: Center(
                child: Text(
                  '60'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '86'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
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
              child: Center(
                child: Text(
                  '61'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
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
