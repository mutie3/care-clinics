import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller; // إضافة الـ controller
  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return IntlPhoneField(
        controller: controller, // ربط الـ controller مع IntlPhoneField
        decoration: InputDecoration(
          labelText: '41'.tr,
          labelStyle: const TextStyle(color: AppColors.textColor),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(),
          ),
        ),
        initialCountryCode: 'JO', // اختيار كود الأردن كقيمة افتراضية
        onChanged: (phone) {
          // يمكنك استخدام phone هنا إذا أردت تخزينه أو معالجته
        },
      );
    });
  }
}
