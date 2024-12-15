import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/add_doctor_button.dart';
import 'package:care_clinic/widgets/doctor_form.dart';
import 'package:get/get.dart';
import 'loading_overlay.dart';

class ClincInfo extends StatefulWidget {
  final String clinicId;

  const ClincInfo({Key? key, required this.clinicId}) : super(key: key);

  @override
  State<ClincInfo> createState() => _ClincInfoState();
}

class _ClincInfoState extends State<ClincInfo> {
  List<Map<String, dynamic>> doctorForms = [];
  Random random = Random();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _addDoctorForm();
  }

  void _addDoctorForm() {
    setState(() {
      int uniqueKey = random.nextInt(10000);
      doctorForms.add({
        'key': uniqueKey,
        'formKey': GlobalKey<FormState>(),
        'nameController': TextEditingController(),
        'specialtyController': TextEditingController(),
        'experienceController': TextEditingController(),
        'daysSelected': ValueNotifier<List<bool>>(List<bool>.filled(7, false)),
        'imageFile': null,
      });
    });
  }

  void _removeDoctorForm(int uniqueKey) {
    setState(() {
      doctorForms.removeWhere((form) => form['key'] == uniqueKey);
    });
  }

  Future<void> _saveDoctorData() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingOverlay(message: '101'.tr);
      },
    );

    try {
      for (var form in doctorForms) {
        GlobalKey<FormState> formKey = form['formKey'];
        TextEditingController nameController = form['nameController'];
        TextEditingController specialtyController = form['specialtyController'];
        TextEditingController experienceController =
            form['experienceController'];
        ValueNotifier<List<bool>> daysSelected = form['daysSelected'];
        File? imageFile = form['imageFile'];

        // Validate form fields
        if (!formKey.currentState!.validate() ||
            nameController.text.isEmpty ||
            specialtyController.text.isEmpty ||
            experienceController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('140'.tr)),
          );
          continue;
        }

        // Upload image if available
        String imageUrl = '';
        if (imageFile != null) {
          try {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('doctor_images/${form['key']}_profile.jpg');
            final uploadTask = await storageRef.putFile(imageFile);
            imageUrl = await uploadTask.ref.getDownloadURL();
          } catch (e) {
            print("Failed to upload image: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
            continue;
          }
        }

        // Collect selected working days
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
        for (int i = 0; i < daysSelected.value.length; i++) {
          if (daysSelected.value[i]) {
            selectedDays.add(days[i]);
          }
        }

        // Prepare doctor data with parsed experience
        var doctorData = {
          'name': nameController.text,
          'specialty': specialtyController.text,
          'experience': int.tryParse(experienceController.text) ??
              0, // Parse experience to integer
          'working_days': selectedDays,
          'image_url': imageUrl,
        };

        // Save doctor data to Firestore
        await FirebaseFirestore.instance
            .collection('clinics')
            .doc(widget.clinicId)
            .collection('doctors')
            .add(doctorData);

        print('109'.tr);
      }

      // Clear forms after saving
      setState(() {
        doctorForms.clear();
        _addDoctorForm(); // Add a new form after saving
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('110'.tr)),
      );
    } catch (e) {
      print('Error saving doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving doctors: $e')),
      );
    } finally {
      Navigator.of(context).pop(); // Hide loading overlay
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '69'.tr,
            style: const TextStyle(color: AppColors.textColor),
          ),
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                DoctorList(
                  doctorForms: doctorForms,
                  onRemove: _removeDoctorForm,
                  clinicId: widget.clinicId,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AddDoctorButton(onPressed: _addDoctorForm),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
