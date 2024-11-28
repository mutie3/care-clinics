import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'about_app_screen.dart';
import 'user_appointments_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? birthday;

  String? imagePath;

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            firstName = userDoc['firstName'] as String?;
            lastName = userDoc['lastName'] as String?;
            phone = userDoc['phone'] as String?;
            email = userDoc['email'] as String?;
            birthday = userDoc['birthday'] as String?;
          });
        }
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> _sendWhatsAppMessage() async {
    final Uri whatsappUrl = Uri.parse(
        "https://wa.me/+962777163292?text=هل ممكن أن احصل على استفسار");
    launchUrl(whatsappUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('الملف الشخصي'),
            centerTitle: true,
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.settings),
              color: themeProvider.isDarkMode
                  ? Colors.grey
                  : AppColors.scaffoldBackgroundColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${firstName ?? ''} ${lastName ?? ''}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email ?? '',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 30,
                            backgroundImage: imagePath != null
                                ? Image.file(File(imagePath!)).image
                                : null,
                            child: imagePath == null
                                ? Text(
                                    firstName != null && firstName!.isNotEmpty
                                        ? firstName![0]
                                        : '...',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey
                                          : AppColors.textBox,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: themeProvider.isDarkMode
                                  ? Colors.grey
                                  : AppColors.primaryColor,
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: const Text('الرقم'),
                  trailing: Text(
                    '0$phone',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('تاريخ الميلاد'),
                  trailing: Text(
                    birthday ?? '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('المواعيد'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserAppointmentsPage()),
                    );
                  },
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.grey
                            : AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _sendWhatsAppMessage,
                      icon: const Icon(Icons.help),
                      label: const Text('احصل على المساعدة'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.grey
                            : AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutAppScreen()),
                        );
                      },
                      icon: const Icon(Icons.info),
                      label: const Text('حول التطبيق'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
