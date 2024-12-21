import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class BirthdayField extends StatefulWidget {
  final TextEditingController controller;

  const BirthdayField({super.key, required this.controller});

  @override
  BirthdayFieldState createState() => BirthdayFieldState();
}

class BirthdayFieldState extends State<BirthdayField> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        widget.controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            _selectDate(context);
          },
          child: AbsorbPointer(
            child: CustomTextField(
              text: '51'.tr,
              icon: Icon(
                Icons.calendar_today,
                color: themeProvider.isDarkMode
                    ? AppColors.textBox
                    : AppColors.primaryColor,
              ),
              controller: widget.controller, // Pass the controller here
            ),
          ),
        );
      },
    );
  }
}
