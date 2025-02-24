import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/field_regestration/birthday_field.dart';
import 'package:care_clinic/field_regestration/email_field.dart';
import 'package:care_clinic/field_regestration/gender_selection.dart';
import 'package:care_clinic/field_regestration/name_field.dart';
import 'package:care_clinic/field_regestration/password_field.dart';
import 'package:care_clinic/field_regestration/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/doctor_reg/loading_overlay.dart';
import '../screens/login_page.dart';
import 'auth_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _gendercontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
            title: Text(
              '46'.tr,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.isDarkMode
                    ? Colors.grey
                    : AppColors.scaffoldBackgroundColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NameField(
                        controllerFirstName: _firstNameController,
                        controllerLastName:
                            _lastNameController), // تمرير المتحكمات للأسماء
                    const SizedBox(height: 18),
                    EmailField(controller: _emailController),
                    const SizedBox(height: 18),
                    PasswordField(controller: _passwordController),
                    const SizedBox(height: 18),
                    BirthdayField(controller: _birthdayController),
                    const SizedBox(height: 18),
                    PhoneField(
                      controller: _phonecontroller,
                    ),
                    const SizedBox(height: 18),
                    GenderSelection(
                      controller: _gendercontroller,
                    ),
                    const SizedBox(height: 22),

                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          final authService = AuthService();

                          // عرض شاشة التحميل
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // لا يمكن إغلاقها بالنقر على الخلفية
                            builder: (BuildContext context) {
                              return LoadingOverlay(message: '94'.tr);
                            },
                          );

                          bool result = await authService.signup(
                            _emailController.text,
                            _passwordController.text,
                          );

                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();

                          if (result) {
                            final user = authService.user;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .set({
                              'firstName': _firstNameController.text,
                              'lastName': _lastNameController.text,
                              'email': _emailController.text,
                              'birthday': _birthdayController.text,
                              'phone': _phonecontroller.text,
                              'gender': _gendercontroller.text,
                            });

                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('95'.tr)),
                            );

                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (Route<dynamic> route) =>
                                    false, // حذف جميع الصفحات السابقة
                              );
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('96'.tr)),
                                );
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.grey
                            : AppColors.primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          '55'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.scaffoldBackgroundColor,
                          ),
                        ),
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
