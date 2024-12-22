import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDoctorButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddDoctorButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '71'.tr,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.add,
              color: AppColors.textColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
