// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/upload_file.dart';
import 'package:care_clinic/widgets/animate_navigation_route.dart';
import 'package:care_clinic/widgets/custom_email_text_field.dart';
import 'package:care_clinic/widgets/custom_location_picker.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:care_clinic/widgets/set_picture.dart';
import 'package:care_clinic/screens/doctor_reg/doctor_info.dart';
import 'package:get/get.dart';

import '../../widgets/custom_phone_field.dart';
import 'loading_overlay.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  File? selectedFile;

  // قائمة التخصصات
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

  Future<void> _uploadData() async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingOverlay(message: '98'.tr);
      },
    );

    try {
      // Create user with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? imageUrl;
      String? fileUrl;

      // Upload image (if selected)
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('clinic_images/${userCredential.user!.uid}_profile.jpg');
        final uploadTask = await storageRef.putFile(_image!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Upload file (if selected)
      if (selectedFile != null) {
        final fileRef = FirebaseStorage.instance
            .ref()
            .child('clinic_files/${userCredential.user!.uid}_file.pdf');
        final uploadTask = await fileRef.putFile(selectedFile!);
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      // Save clinic data to Firestore
      final clinicId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('clinics').doc(clinicId).set({
        'name': nameController.text,
        'email': emailController.text,
        'location': locationController.text,
        'phone': phoneController.text,
        // 'imageUrl': imageUrl,
        // 'fileUrl': fileUrl,
      });

      if (mounted) {
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('99'.tr)),
        );
        Navigator.of(context).pop(); // Dismiss loading overlay
        Navigator.of(context).push(animateRoute(ClincInfo(clinicId: clinicId)));
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        Navigator.of(context).pop(); // Dismiss loading overlay

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text("An error occurred: ${e.toString()} ,"),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      // Ensure the widget is still mounted before calling Navigator
                      Navigator.of(context).pop(); // Close the dialog
                    }
                  },
                  child: Text('148'.tr),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '56'.tr,
            style: const TextStyle(
              color: AppColors.textColor,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SetProfilePicture(
                    onImagePicked: (File file) {
                      setState(() {
                        _image = file;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    text: '57'.tr,
                    controller: nameController,
                    icon: const Icon(Icons.local_hospital_outlined,
                        color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  CustomPhoneField(controller: phoneController),
                  const SizedBox(height: 20),
                  CustomEmailTextField(
                    text: '50'.tr,
                    controller: emailController,
                    icon:
                        const Icon(Icons.email, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    text: '49'.tr,
                    controller: passwordController,
                    obscureText: true,
                    icon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '87'.tr;
                      } else if (value.length < 6) {
                        return '88'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomLocationPicker(controller: locationController),
                  const SizedBox(height: 20),
                  UploadFile(
                    onFilePicked: (File file) {
                      setState(() {
                        selectedFile = file;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      '100'.tr,
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
