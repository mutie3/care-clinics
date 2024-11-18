import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? text;
  final Icon? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;

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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: const TextStyle(color: AppColors.textColor),
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        labelText: text,
        labelStyle: const TextStyle(color: AppColors.textColor),
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
      ),
    );
  }
}
