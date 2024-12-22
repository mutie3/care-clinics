import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/theme_dark_mode.dart';

class CustomTextField extends StatelessWidget {
  final String? text;
  final Icon? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool? enabled;

  const CustomTextField({
    super.key,
    required this.text,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          onChanged: onChanged,
          enabled: enabled,
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? Colors.white // النص في الوضع المظلم يكون أبيض
                : Colors.black, // النص في الوضع العادي يكون أسود
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            hintText: text,
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors
                      .grey.shade500 // تلميح في الوضع المظلم بلون رمادي خفيف
                  : AppColors.textColor, // تلميح في الوضع العادي
              fontFamily: 'Tajawal',
            ),
            prefixIcon: icon,
            suffixIcon: suffixIcon,
            labelText: text,
            labelStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.white // التسمية في الوضع المظلم تكون بيضاء
                  : AppColors.textColor, // التسمية في الوضع العادي
              fontFamily: 'Tajawal',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                    : AppColors.primaryColor, // حدود في الوضع الفاتح
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.blueGrey
                        .shade300 // الحدود عندما يكون الحقل متركزًا في الوضع المظلم
                    : AppColors
                        .primaryColor, // الحدود عندما يكون الحقل متركزًا في الوضع العادي
              ),
            ),
          ),
        );
      },
    );
  }
}
