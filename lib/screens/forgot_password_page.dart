import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_clinic/constants/colors_page.dart';
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
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // استخدم CustomTextField بدلاً من TextFormField العادي
              CustomTextField(
                text: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
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
                      // محاولة إرسال رابط إعادة تعيين كلمة المرور
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent.'),
                        ),
                      );
                      Navigator.pop(
                          context); // العودة إلى صفحة تسجيل الدخول بعد الإرسال
                    } on FirebaseAuthException catch (e) {
                      // التعامل مع الأخطاء الممكنة من Firebase
                      String errorMessage = '';
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = 'The email address is not valid.';
                          break;
                        case 'user-not-found':
                          errorMessage = 'No user found for that email.';
                          break;
                        case 'too-many-requests':
                          errorMessage =
                              'Too many requests. Please try again later.';
                          break;
                        case 'network-request-failed':
                          errorMessage =
                              'Network error. Please check your internet connection.';
                          break;
                        default:
                          errorMessage =
                              'An unknown error occurred. Please try again.';
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
                child: const Text(
                  'Send Reset Email',
                  style: TextStyle(
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
