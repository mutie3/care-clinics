import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';

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
        const Text(
          'What is your gender?',
          style: TextStyle(
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
                  _gender = 'Male';
                  widget.controller.text = _gender!; // حفظ القيمة في controller
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: _gender == 'Male'
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    radius: 30,
                    child: Icon(
                      Icons.male,
                      size: 40,
                      color: _gender == 'Male' ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('Male',
                      style: TextStyle(color: AppColors.textColor)),
                ],
              ),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  _gender = 'Female';
                  widget.controller.text = _gender!; // حفظ القيمة في controller
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: _gender == 'Female'
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    radius: 30,
                    child: Icon(
                      Icons.female,
                      size: 40,
                      color: _gender == 'Female' ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('Female',
                      style: TextStyle(color: AppColors.textColor)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
