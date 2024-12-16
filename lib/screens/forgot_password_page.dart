import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:get/get.dart';
import '../widgets/custom_text_fieled.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('63'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                text: '160'.tr,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '84'.tr;
                  }
                  return null;
                },
                icon: const Icon(Icons.email, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('161'.tr),
                        ),
                      );
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      String errorMessage = '';
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = '162'.tr;
                          break;
                        case 'user-not-found':
                          errorMessage = '163'.tr;
                          break;
                        case 'too-many-requests':
                          errorMessage = '164'.tr;
                          break;
                        case 'network-request-failed':
                          errorMessage = '165'.tr;
                          break;
                        default:
                          errorMessage = '166'.tr;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                        ),
                      );
                    } catch (e) {
                      // في حال حدوث أي خطأ آخر
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An unexpected error occurred: $e'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text(
                  '167'.tr,
                  style: const TextStyle(
                      fontSize: 18, color: AppColors.scaffoldBackgroundColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
