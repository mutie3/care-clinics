import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderSelection extends StatefulWidget {
  final TextEditingController controller;
  const GenderSelection({super.key, required this.controller});

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '52'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _gender = '53'.tr;
                  widget.controller.text = _gender!; // حفظ القيمة في controller
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: _gender == '53'.tr
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    radius: 30,
                    child: Icon(
                      Icons.male,
                      size: 40,
                      color: _gender == '53'.tr ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('53'.tr,
                      style: const TextStyle(color: AppColors.textColor)),
                ],
              ),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  _gender = '54'.tr;
                  widget.controller.text = _gender!; // حفظ القيمة في controller
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: _gender == '54'.tr
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    radius: 30,
                    child: Icon(
                      Icons.female,
                      size: 40,
                      color: _gender == '54'.tr ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('54'.tr,
                      style: const TextStyle(color: AppColors.textColor)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
