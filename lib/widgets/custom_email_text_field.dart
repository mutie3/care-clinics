import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';

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
            hintStyle: const TextStyle(
              color: AppColors.textColor,
              fontFamily: 'Tajawal',
            ),
            prefixIcon: icon,
            suffixIcon: suffixIcon,
            labelText: text,
            labelStyle: const TextStyle(
              color: AppColors.textColor,
              fontFamily: 'Tajawal',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
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
  }
}
