import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'about_app_screen.dart';
import 'appointment_confirmation_page.dart';
import 'rating_page.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  String userName = 'Mutie Abu Zanat';

  String? imagePath;

  final ImagePicker _picker = ImagePicker();

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
        "https://wa.me/+962792808314?text=هل ممكن أن احصل على استفسار");
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mutie Abu Zanat',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
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
                                    'M',
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
                const ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('الرقم'),
                  trailing: Text(
                    '0792808314',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('السجل الطبي'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RatingPage(
                                doctorId: '123456',
                              )),
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
