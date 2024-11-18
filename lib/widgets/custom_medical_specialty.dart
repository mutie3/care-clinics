import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';

class CustomMedicalSpacialty extends StatelessWidget {
  final List<String> medicalSpecialties = [
    "General Medicine / Family Medicine",
    "Internal Medicine",
    "Pediatrics",
    "Obstetrics and Gynecology",
    "Dermatology",
    "Cardiology",
    "Orthopedic Surgery",
    "Psychiatry",
    "Endocrinology",
    "Gastroenterology",
    "Respiratory Medicine",
    "Nephrology and Urology",
    "Oncology and Radiotherapy",
    "Sports Medicine",
    "Hematology",
    "Hepatology",
    "Infectious Diseases",
    "Nutrition and Dietetics",
    "Ophthalmology",
    "Otorhinolaryngology (ENT - Ear, Nose, and Throat)",
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
        hintText: "Medical Specialty",
        hintStyle: const TextStyle(color: AppColors.textColor),
        labelText: "Medical Specialty",
        labelStyle: const TextStyle(color: AppColors.textColor),
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
