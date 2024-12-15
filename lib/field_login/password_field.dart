import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_fieled.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller; // إضافة متحكم TextEditingController

  const PasswordField({Key? key, required this.controller}) : super(key: key);

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
          text: '49'.tr,
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
              return '87'.tr;
            }
            if (value.length < 6) {
              return '88'.tr;
            }
            return null;
          },
        );
      },
    );
  }
}
