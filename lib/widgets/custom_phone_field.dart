import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:provider/provider.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;

  const CustomPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IntlPhoneField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '41'.tr,
            labelStyle: const TextStyle(
              color: AppColors.scaffoldBackgroundColor,
              fontFamily: 'Tajawal',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade600
                    : AppColors.primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade600
                    : AppColors.primaryColor,
              ),
            ),
          ),
          initialCountryCode: 'JO',
          onChanged: (phone) {
            // يمكنك إضافة منطق للتعامل مع تغيير الرقم هنا إذا لزم الأمر
          },
        );
      },
    );
  }
}
