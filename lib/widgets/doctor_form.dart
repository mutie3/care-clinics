import 'dart:io';
import 'package:care_clinic/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/set_picture.dart';

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
  ];

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
                  widget.onImageChanged(file);
                },
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              text: "Doctor Name",
              controller: widget.nameController,
              icon: const Icon(Icons.person_outline_outlined,
                  color: AppColors.primaryColor),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter doctor name'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.specialtyController.text.isNotEmpty
                  ? widget.specialtyController.text
                  : selectedSpecialty,
              decoration: const InputDecoration(
                labelText: "Specialty",
                prefixIcon:
                    Icon(Icons.medical_services, color: AppColors.primaryColor),
                border: OutlineInputBorder(),
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
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select a specialty'
                  : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              keyboardType: TextInputType.number,
              text: "Experience Years",
              controller: widget.experienceController,
              icon: const Icon(Icons.more_time, color: AppColors.primaryColor),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter experience years'
                  : null,
            ),
            const SizedBox(height: 15),
            const Text(
              "Working Days:",
              style: TextStyle(
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
                  const days = [
                    "SUN",
                    "MON",
                    "TUE",
                    "WED",
                    "THU",
                    "FRI",
                    "SAT"
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

    try {
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
              const SnackBar(content: Text('Please select a valid specialty.')),
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'تم حفظ الدكاترة سوف يتم التاكد من المعلومات خلال 24 ساعة.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please fill all fields for all doctors.')),
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
    return Column(
      children: [
        widget.doctorForms.isEmpty
            ? const Center(
                child: Text(
                  "No doctors added yet. Please add a doctor to continue.",
                  style: TextStyle(fontSize: 18, color: AppColors.textColor),
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
          child: const Text("Save All Doctors"),
        ),
      ],
    );
  }
}
