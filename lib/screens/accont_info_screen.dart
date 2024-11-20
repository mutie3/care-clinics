import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'login_page.dart'; // استيراد صفحة تسجيل الدخول

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  AccountInfoScreenState createState() => AccountInfoScreenState();
}

class AccountInfoScreenState extends State<AccountInfoScreen> {
  bool isEditing = false;
  DateTime? birthDate;
  String gender = 'ذكر';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          emailController.text = data['email'] ?? '';
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          phoneController.text = data['phone'] ?? '';
          gender = data['gender'] ?? 'ذكر';
          birthDate = data['birthday'] != null
              ? DateTime.parse(data['birthday'])
              : null;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      final formattedDate = birthDate != null
          ? DateFormat('yyyy-MM-dd').format(birthDate!)
          : null;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'email': emailController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phone': phoneController.text,
        'gender': gender,
        'birthday': formattedDate,
      });

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
      );
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال كلمة المرور لتأكيد الحذف.'),
            const SizedBox(height: 16),
            CustomTextField(
              text: 'كلمة المرور',
              controller: passwordController,
              icon: const Icon(Icons.lock),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال كلمة المرور')),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              try {
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: password,
                );

                await user.reauthenticateWithCredential(credential);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .delete();
                await user.delete();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور غير صحيحة'),
                  ),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('معلومات الحساب'),
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (isEditing) {
                    _updateUserData();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  text: 'البريد الإلكتروني',
                  controller: emailController,
                  icon: const Icon(Icons.email),
                  enabled: isEditing,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  text: 'الاسم الأول',
                  controller: firstNameController,
                  icon: const Icon(Icons.person),
                  enabled: isEditing,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  text: 'الاسم الأخير',
                  controller: lastNameController,
                  icon: const Icon(Icons.person_outline),
                  enabled: isEditing,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (isEditing) {
                      _selectBirthDate(context);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'تاريخ الميلاد',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      birthDate == null
                          ? 'اختر تاريخ الميلاد'
                          : DateFormat('yyyy-MM-dd').format(birthDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف الحساب'),
                  onPressed: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
