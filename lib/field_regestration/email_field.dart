import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_fieled.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CustomTextField(
          controller: controller,
          text: 'Email',
          icon: Icon(
            Icons.email,
            color: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        );
      },
    );
  }
}
