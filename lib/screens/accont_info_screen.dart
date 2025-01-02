import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  AccountInfoScreenState createState() => AccountInfoScreenState();
}

class AccountInfoScreenState extends State<AccountInfoScreen> {
  bool isEditing = false;
  DateTime? birthDate;
  String gender = '33'.tr;

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
      if (user == null) throw Exception('150'.tr);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
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
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('150'.tr);

      final formattedDate = birthDate != null
          ? DateFormat('yyyy-MM-dd').format(birthDate!)
          : null;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phone': phoneController.text,
        'gender': gender,
        'birthday': formattedDate,
      });

      setState(() {
        isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('150'.tr)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('154'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('152'.tr),
            const SizedBox(height: 16),
            CustomTextField(
              text: '49'.tr,
              controller: passwordController,
              icon: const Icon(Icons.lock),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('117'.tr),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('153'.tr)),
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
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('155'.tr),
                    ),
                  );
                }
              }
            },
            child: Text('78'.tr),
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
            title: Text(
              '25'.tr, // Use the translation for title text here
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
                  colors: themeProvider.isDarkMode
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
                const SizedBox(height: 16),
                CustomTextField(
                  text: '47'.tr,
                  controller: firstNameController,
                  icon: const Icon(Icons.person),
                  enabled: isEditing,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  text: '48'.tr,
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
                      labelText: '51'.tr,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      birthDate == null
                          ? '156'
                              .tr // Placeholder text when date is not selected
                          : DateFormat('yyyy-MM-dd').format(birthDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Transparent background
                    side: const BorderSide(
                        color: Colors.red, width: 2), // Red border
                    foregroundColor: Colors.red, // Red text and icon color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    elevation: 0, // No shadow to keep it clean
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20), // Comfortable padding
                  ),
                  icon: const Icon(
                    Icons.delete,
                    size: 24, // Icon size
                  ),
                  label: Text(
                    '157'.tr, // Text inside the button
                    style: const TextStyle(
                      fontSize: 18, // Text size
                      fontWeight: FontWeight.bold,
                      // Bold text
                    ),
                  ),
                  onPressed: _showDeleteAccountDialog,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
