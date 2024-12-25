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
import 'package:provider/provider.dart';
import '../../constants/theme_dark_mode.dart';
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingOverlay(message: '98'.tr);
      },
    );

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? imageUrl;
      String? fileUrl;

      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('clinic_images/${userCredential.user!.uid}_profile.jpg');
        final uploadTask = await storageRef.putFile(_image!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      if (selectedFile != null) {
        final fileRef = FirebaseStorage.instance
            .ref()
            .child('clinic_files/${userCredential.user!.uid}_file.pdf');
        final uploadTask = await fileRef.putFile(selectedFile!);
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      final clinicId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('clinics').doc(clinicId).set({
        'name': nameController.text,
        'email': emailController.text,
        'location': locationController.text,
        'phone': phoneController.text,
        'isApproved': false,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
        'clinicRating': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('99'.tr)),
        );
        Navigator.of(context).pop();
        Navigator.of(context).push(animateRoute(ClincInfo(clinicId: clinicId)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

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
                      Navigator.of(context).pop();
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '56'.tr,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : AppColors.textColor,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            backgroundColor: themeProvider.isDarkMode
                ? Colors.black
                : AppColors.primaryColor,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : AppColors.textColor,
              ),
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
                      icon: Icon(Icons.local_hospital_outlined,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : AppColors.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    CustomPhoneField(controller: phoneController),
                    const SizedBox(height: 20),
                    CustomEmailTextField(
                      text: '50'.tr,
                      controller: emailController,
                      icon: Icon(Icons.email,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : AppColors.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      text: '49'.tr,
                      controller: passwordController,
                      obscureText: true,
                      icon: Icon(Icons.lock,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : AppColors.primaryColor),
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
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.black
                            : AppColors.primaryColor,
                      ),
                      child: Text(
                        '100'.tr,
                        style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : AppColors.textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
