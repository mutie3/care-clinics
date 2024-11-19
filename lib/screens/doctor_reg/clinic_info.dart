import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/Upload_File.dart';
import 'package:care_clinic/widgets/animate_navigation_route.dart';
import 'package:care_clinic/widgets/custom_email_text_field.dart';
import 'package:care_clinic/widgets/custom_location_picker.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:care_clinic/widgets/set_picture.dart';
import 'package:care_clinic/screens/doctor_reg/doctor_info.dart';

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
    // عرض شاشة التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay(message: "Registering clinic...");
      },
    );

    try {
      // إنشاء مستخدم جديد باستخدام Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? imageUrl;
      String? fileUrl;

      // رفع الصورة إلى Firebase Storage
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('clinic_images/${userCredential.user!.uid}_profile.jpg');
        final uploadTask = await storageRef.putFile(_image!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // رفع الملف إلى Firebase Storage
      if (selectedFile != null) {
        final fileRef = FirebaseStorage.instance
            .ref()
            .child('clinic_files/${userCredential.user!.uid}_file.pdf');
        final uploadTask = await fileRef.putFile(selectedFile!);
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      // حفظ بيانات العيادة في Firestore
      final clinicId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('clinics').doc(clinicId).set({
        'name': nameController.text,
        'email': emailController.text,
        'location': locationController.text,
        'phone': phoneController.text,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinic data uploaded successfully')),
      );

      // التنقل إلى صفحة المعلومات بعد التسجيل الناجح
      Navigator.of(context).pop();
      Navigator.of(context).push(animateRoute(ClincInfo(clinicId: clinicId)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Clinic Information",
            style: TextStyle(color: AppColors.textColor),
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
                    text: "Clinic Name",
                    controller: nameController,
                    icon: const Icon(Icons.local_hospital_outlined,
                        color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  CustomPhoneField(controller: phoneController),
                  const SizedBox(height: 20),
                  CustomEmailTextField(
                    text: 'Email',
                    controller: emailController,
                    icon:
                        const Icon(Icons.email, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    text: "Password",
                    controller: passwordController,
                    obscureText: true,
                    icon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
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
                    child: const Text(
                      'Register Clinic',
                      style: TextStyle(color: AppColors.textColor),
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
