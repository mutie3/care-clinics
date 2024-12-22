import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/add_doctor_button.dart';
import 'package:care_clinic/widgets/doctor_form.dart';

import 'loading_overlay.dart';

class ClincInfo extends StatefulWidget {
  final String clinicId;

  const ClincInfo({super.key, required this.clinicId});

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay(message: "Saving doctor data...");
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

        if (!formKey.currentState!.validate() ||
            nameController.text.isEmpty ||
            specialtyController.text.isEmpty ||
            experienceController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all the fields')),
          );
          continue;
        }

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

        List<String> selectedDays = [];
        const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        for (int i = 0; i < daysSelected.value.length; i++) {
          if (daysSelected.value[i]) {
            selectedDays.add(days[i]);
          }
        }

        var doctorData = {
          'name': nameController.text,
          'specialty': specialtyController.text,
          'experience': int.tryParse(experienceController.text) ?? 0,
          'working_days': selectedDays,
          'image_url': imageUrl,
        };

        await FirebaseFirestore.instance
            .collection('clinics')
            .doc(widget.clinicId)
            .collection('doctors')
            .add(doctorData);

        print("Doctor data uploaded successfully");
      }

      setState(() {
        doctorForms.clear();
        _addDoctorForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctors saved successfully')),
      );
    } catch (e) {
      print('Error saving doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving doctors: $e')),
      );
    } finally {
      Navigator.of(context).pop();
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
          title: const Text(
            "Doctor Information",
            style: TextStyle(color: AppColors.textColor),
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
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
