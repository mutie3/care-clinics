import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_fieled.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller; // إضافة متحكم TextEditingController

  const PasswordField({super.key, required this.controller});

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CustomTextField(
          text: 'Password',
          controller: widget.controller, // تمرير المتحكم إلى الحقل
          icon: Icon(
            Icons.lock,
            color: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
          ),
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: themeProvider.isDarkMode
                  ? AppColors.textBox
                  : AppColors.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        );
      },
    );
  }
}
