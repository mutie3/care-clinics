import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDoctorButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddDoctorButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 150,
      onPressed: onPressed,
      color: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '71'.tr,
            style: const TextStyle(color: AppColors.textColor, fontSize: 18),
          ),
          const Icon(
            Icons.add,
            color: AppColors.textColor,
          ),
        ],
      ),
    );
  }
}
