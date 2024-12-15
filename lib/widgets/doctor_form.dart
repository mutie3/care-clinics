import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/set_picture.dart';
import 'package:get/get.dart';
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
  });

  @override
  _DoctorFormState createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  String? selectedSpecialty;
  File? selectedImage;

  final List<String> specialties = [
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
  ];

  Future<void> _uploadDoctorData() async {
    try {
      List<String> selectedDays = [];
      var days = [
        '102'.tr,
        '103'.tr,
        '104'.tr,
        '105'.tr,
        '106'.tr,
        '107'.tr,
        '108'.tr
      ];
      for (int i = 0; i < widget.daysSelected.value.length; i++) {
        if (widget.daysSelected.value[i]) {
          selectedDays.add(days[i]);
        }
      }

      String imageUrl = '';
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('doctor_images/${widget.uniqueKey}.jpg');
        final uploadTask = await storageRef.putFile(selectedImage!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .add({
        'name': widget.nameController.text,
        'specialty': selectedSpecialty ?? widget.specialtyController.text,
        'experience': int.tryParse(widget.experienceController.text) ?? 0,
        'working_days': selectedDays,
        'image_url': imageUrl,
      });

      // عرض رسالة نجاح بعد رفع البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('136'.tr)),
      );
    } catch (error) {
      print("Failed to upload doctor data: $error");

      // عرض رسالة خطأ إذا فشل رفع البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.scaffoldBackgroundColor.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.primaryColor),
                onPressed: widget.onDelete,
              ),
            ),
            Center(
              child: SetProfilePicture(
                onImagePicked: (File file) {
                  setState(() {
                    selectedImage = file;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              text: '74'.tr,
              controller: widget.nameController,
              icon: const Icon(Icons.person_outline_outlined,
                  color: AppColors.primaryColor),
              validator: (value) =>
                  value == null || value.isEmpty ? '137'.tr : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedSpecialty,
              decoration: InputDecoration(
                labelText: '75'.tr,
                prefixIcon: const Icon(Icons.medical_services,
                    color: AppColors.primaryColor),
                border: const OutlineInputBorder(),
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
                });
              },
              validator: (value) => value == null ? '138'.tr : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              keyboardType: TextInputType.number,
              text: '73'.tr,
              controller: widget.experienceController,
              icon: const Icon(Icons.more_time, color: AppColors.primaryColor),
              validator: (value) =>
                  value == null || value.isEmpty ? '139'.tr : null,
            ),
            const SizedBox(height: 15),
            Text(
              '72'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(7, (index) {
                  var days = [
                    '102'.tr,
                    '103'.tr,
                    '104'.tr,
                    '105'.tr,
                    '106'.tr,
                    '107'.tr,
                    '108'.tr
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  _uploadDoctorData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('140'.tr)),
                  );
                }
              },
              child: Text('70'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return doctorForms.isEmpty
        ? Center(
            child: Text(
              '141'.tr,
              style: const TextStyle(fontSize: 18, color: AppColors.textColor),
              textAlign: TextAlign.center,
            ),
          )
        : Column(
            children: doctorForms.map((form) {
              return DoctorForm(
                uniqueKey: form['key'],
                formKey: form['formKey'],
                daysSelected: form['daysSelected'],
                onDelete: () => onRemove(form['key']),
                nameController: form['nameController'],
                specialtyController: form['specialtyController'],
                experienceController: form['experienceController'],
                clinicId: clinicId,
              );
            }).toList(),
          );
  }
}
