import 'dart:io';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/set_picture.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_text_fieled.dart';

class DoctorForm extends StatefulWidget {
  final int uniqueKey;
  final GlobalKey<FormState> formKey;
  final ValueNotifier<List<bool>> daysSelected;
  final VoidCallback onDelete;
  final TextEditingController nameController;
  final TextEditingController specialtyController;
  final TextEditingController experienceController;
  final String clinicId;
  final ValueChanged<File?> onImageChanged;

  const DoctorForm({
    super.key,
    required this.uniqueKey,
    required this.formKey,
    required this.daysSelected,
    required this.onDelete,
    required this.nameController,
    required this.specialtyController,
    required this.experienceController,
    required this.clinicId,
    required this.onImageChanged,
  });

  @override
  _DoctorFormState createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  String? selectedSpecialty;
  File? selectedImage;

  final List<String> specialties = [
    'Cardiology', // '20'.tr
    'Dentistry', // Added Dentistry
    'Dermatology', // '19'.tr
    'Endocrinology', // '23'.tr
    'ENT (Ear, Nose, and Throat)', // '13'.tr
    'Gastroenterology', // '3'.tr
    'General Medicine / Family Medicine', // '15'.tr
    'Hematology', // '8'.tr
    'Hepatology', // '9'.tr
    'Infectious Diseases', // '10'.tr
    'Internal Medicine', // '16'.tr
    'Nephrology and Urology', // '5'.tr
    'Nutrition and Dietetics', // '11'.tr
    'Obstetrics and Gynecology', // '18'.tr
    'Ophthalmology', // '12'.tr
    'Orthopedic Surgery', // '21'.tr
    'Pediatrics', // '17'.tr
    'Psychiatry', // '22'.tr
    'Respiratory Medicine', // '4'.tr
    'Sports Medicine', // '7'.tr
    'Oncology and Radiotherapy', // '6'.tr
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Form(
        key: widget.formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.black
                  : AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.scaffoldBackgroundColor.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: themeProvider.isDarkMode
                        ? Colors.red
                        : AppColors.primaryColor,
                  ),
                  onPressed: widget.onDelete,
                ),
              ),
              Center(
                child: SetProfilePicture(
                  onImagePicked: (File file) {
                    setState(() {
                      selectedImage = file;
                    });
                    widget.onImageChanged(file);
                  },
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                text: "74".tr,
                controller: widget.nameController,
                icon: Icon(
                  Icons.person_outline_outlined,
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade600
                      : AppColors.primaryColor,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '137'.tr : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: widget.specialtyController.text.isNotEmpty
                    ? widget.specialtyController.text
                    : selectedSpecialty,
                decoration: InputDecoration(
                  labelText: "75".tr,
                  prefixIcon: Icon(
                    Icons.medical_services,
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                        : AppColors.primaryColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: themeProvider.isDarkMode
                          ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                          : AppColors.primaryColor, // حدود في الوضع الفاتح
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: themeProvider.isDarkMode
                          ? Colors.blueGrey
                              .shade300 // الحدود عندما يكون الحقل متركزًا في الوضع المظلم
                          : AppColors
                              .primaryColor, // الحدود عندما يكون الحقل متركزًا في الوضع العادي
                    ),
                  ),
                ),
                items: specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSpecialty = value;
                    widget.specialtyController.text = value ?? '';
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? '138'.tr : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                keyboardType: TextInputType.number,
                text: "73".tr,
                controller: widget.experienceController,
                icon: Icon(
                  Icons.more_time,
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                      : AppColors.primaryColor,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '139'.tr : null,
              ),
              const SizedBox(height: 15),
              Text(
                "72".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                      : AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(7, (index) {
                    var days = [
                      "SUN",
                      "MON",
                      "TUE",
                      "WED",
                      "THU",
                      "FRI",
                      "SAT",
                    ];

                    return ValueListenableBuilder<List<bool>>(
                      valueListenable: widget.daysSelected,
                      builder: (context, daysList, child) {
                        return GestureDetector(
                          onTap: () {
                            daysList[index] = !daysList[index];
                            widget.daysSelected.value = List.from(daysList);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(2),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: daysList[index]
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  color: daysList[index]
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DoctorList extends StatefulWidget {
  final List<Map<String, dynamic>> doctorForms;
  final Function(int) onRemove;
  final String clinicId;

  const DoctorList({
    super.key,
    required this.doctorForms,
    required this.onRemove,
    required this.clinicId,
  });

  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  Future<void> _saveAllDoctors() async {
    bool hasError = false;
    bool isExistingClinic = false;
    bool isApproved = false; // لتخزين حالة الموافقة على العيادة

    try {
      // التحقق مما إذا كانت العيادة موجودة مسبقًا وجلب حالة isApproved
      final clinicDoc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .get();

      if (clinicDoc.exists) {
        isExistingClinic = true;
        isApproved =
            clinicDoc.data()?['isApproved'] ?? false; // جلب حالة isApproved
      }

      for (var form in widget.doctorForms) {
        if (form['formKey'].currentState!.validate()) {
          List<String> selectedDays = [];
          const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
          for (int i = 0; i < form['daysSelected'].value.length; i++) {
            if (form['daysSelected'].value[i]) {
              selectedDays.add(days[i]);
            }
          }

          String imageUrl = '';
          if (form['selectedImage'] != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('doctor_images/${form['key']}.jpg');
            final uploadTask = await storageRef.putFile(form['selectedImage']);
            imageUrl = await uploadTask.ref.getDownloadURL();
          }

          final specialty = form['specialtyController'].text;

          if (specialty.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('300'.tr)),
            );
            hasError = true;
            break;
          }

          await FirebaseFirestore.instance
              .collection('clinics')
              .doc(widget.clinicId)
              .collection('doctors')
              .add({
            'name': form['nameController'].text,
            'specialty': specialty,
            'experience': int.tryParse(form['experienceController'].text) ?? 0,
            'working_days': selectedDays,
            'image_url': imageUrl,
          });

          // عرض SnackBar فقط إذا كانت العيادة غير معتمدة
          if (!isApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('عيادتك لم يتم الموافقة عليها بعد'.tr)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('298'.tr)),
          );
          hasError = true;
          break;
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save doctors: $error')),
      );
      hasError = true;
    }

    if (!hasError) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Column(
        children: [
          widget.doctorForms.isEmpty
              ? Center(
                  child: Text(
                    "141".tr,
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.textColor),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: widget.doctorForms.map((form) {
                    return DoctorForm(
                      uniqueKey: form['key'],
                      formKey: form['formKey'],
                      daysSelected: form['daysSelected'],
                      onDelete: () => widget.onRemove(form['key']),
                      nameController: form['nameController'],
                      specialtyController: form['specialtyController'],
                      experienceController: form['experienceController'],
                      clinicId: widget.clinicId,
                      onImageChanged: (file) => form['selectedImage'] = file,
                    );
                  }).toList(),
                ),
          ElevatedButton(
            onPressed: _saveAllDoctors,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.black
                  : AppColors.primaryColor,
            ),
            child: Text(
              "297".tr,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade600 // حدود داكنة في الوضع الغامق
                    : Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }
}
