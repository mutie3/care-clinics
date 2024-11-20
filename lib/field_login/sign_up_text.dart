import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/regestration_as_screen.dart';

class SignUpText extends StatelessWidget {
  const SignUpText({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegAsSelect(),
                ),
              );
            },
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: AppColors.textBox,
                    ),
                  ),
                  TextSpan(
                    text: "Registration",
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
