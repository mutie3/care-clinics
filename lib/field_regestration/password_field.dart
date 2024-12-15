import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_fieled.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;
  String? _errorText;

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _errorText = '49'.tr;
      });
    } else if (value.length < 6) {
      setState(() {
        _errorText = '88'.tr;
      });
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      setState(() {
        _errorText = '142'.tr;
      });
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      setState(() {
        _errorText = '143'.tr;
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              text: 'Password',
              controller: widget.controller,
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
              onChanged: (value) {
                _validatePassword(value);
              },
            ),
            if (_errorText != null) // عرض رسالة الخطأ إن وجدت
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
