import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:get/get.dart';
import '../widgets/custom_text_fieled.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '229'.tr, // Use the translation for title text here
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [Colors.blueGrey, Colors.blueGrey.shade700]
                  : [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                text: '230'.tr, // Change the text here
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '231'.tr; // "Current password is required"
                  }
                  return null;
                },
                icon: const Icon(Icons.lock, color: AppColors.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                text: '232'.tr, // Change the text here
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '233'.tr; // "New password is required"
                  }
                  if (value.length < 6) {
                    return '234'.tr; // "Password must be at least 6 characters"
                  }
                  return null;
                },
                icon: const Icon(Icons.lock_outline,
                    color: AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                text: '235'.tr, // Change the text here
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '236'.tr; // "Confirm password is required"
                  }
                  if (value != _newPasswordController.text) {
                    return '237'.tr; // "Passwords do not match"
                  }
                  return null;
                },
                icon: const Icon(Icons.lock_outline,
                    color: AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;

                      // Re-authenticate the user with current password
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user!.email!,
                        password: _currentPasswordController.text,
                      );

                      await user.reauthenticateWithCredential(credential);

                      // Change the password
                      await user.updatePassword(_newPasswordController.text);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('238'.tr), // "Password updated successfully"
                        ),
                      );
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      String errorMessage = '';
                      switch (e.code) {
                        case 'wrong-password':
                          errorMessage = '239'.tr; // "Wrong current password"
                          break;
                        default:
                          errorMessage = 'An error occurred: ${e.message}';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                        ),
                      );
                    } catch (e) {
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
                  '229'.tr, // Change the text here
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
