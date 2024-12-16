import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomMedicalSpacialty extends StatelessWidget {
  final List<String> medicalSpecialties = [
    '15'.tr,
    '16'.tr,
    '17'.tr,
    '18'.tr,
    '19'.tr,
    '20'.tr,
    '21'.tr,
    '22'.tr,
    '23'.tr,
    '3'.tr,
    '4'.tr,
    '5'.tr,
    '6'.tr,
    '7'.tr,
    '8'.tr,
    '9'.tr,
    '10'.tr,
    '11'.tr,
    '12'.tr,
    '13'.tr,
  ];

  CustomMedicalSpacialty({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.medical_services_outlined,
          color: AppColors.primaryColor,
        ),
        hintText: '2'.tr,
        hintStyle: const TextStyle(
          color: AppColors.textColor,
          fontFamily: 'Tajawal',
        ),
        labelText: '2'.tr,
        labelStyle: const TextStyle(
          color: AppColors.textColor,
          fontFamily: 'Tajawal',
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
      ),
      value: null,
      onChanged: (String? newValue) {},
      items: medicalSpecialties.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      isExpanded: true,
    );
  }
}
