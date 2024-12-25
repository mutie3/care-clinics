import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // لاستخدام Consumer لمتابعة الوضع المظلم

class CustomEmailTextField extends StatelessWidget {
  const CustomEmailTextField({
    super.key,
    required this.text,
    this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.validator, // إضافة خاصية validator هنا
  });

  final String text;
  final Icon? icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator; // تعريف validator

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              obscureText: obscureText,
              onChanged: (value) {
                if (onChanged != null) {
                  onChanged!(value);
                }
              },
              validator: validator, // استخدام validator هنا
              decoration: InputDecoration(
                hintText: text,
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors
                          .grey.shade500 // تلميح باللون الرمادي في الوضع المظلم
                      : AppColors
                          .textColor, // تلميح باللون الأساسي في الوضع الفاتح
                  fontFamily: 'Tajawal',
                ),
                prefixIcon: icon,
                suffixIcon: suffixIcon,
                labelText: text,
                labelStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white // التسمية باللون الأبيض في الوضع المظلم
                      : AppColors
                          .textColor, // التسمية باللون الأساسي في الوضع الفاتح
                  fontFamily: 'Tajawal',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade600 // حدود داكنة في الوضع المظلم
                        : AppColors.primaryColor, // حدود ملونة في الوضع الفاتح
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: themeProvider.isDarkMode
                        ? Colors
                            .blueGrey.shade300 // حدود التركيز في الوضع المظلم
                        : AppColors
                            .primaryColor, // حدود التركيز في الوضع الفاتح
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: Colors.red, // اللون الأحمر عند وجود خطأ
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: Colors.red,
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
