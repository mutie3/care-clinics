import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:provider/provider.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;

  const CustomPhoneField({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IntlPhoneField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: const TextStyle(
              color: AppColors.textColor,
              fontFamily: 'Tajawal',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : AppColors.primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white
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
