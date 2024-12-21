import 'package:care_clinic/screens/drug_info_page.dart';
import 'package:care_clinic/screens/setting_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/theme_dark_mode.dart';
import 'about_app_screen.dart';
import 'accont_info_screen.dart';
import 'home_page.dart';
import 'user_appointments_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // استيراد الخطوط
import 'package:care_clinic/constants/colors_page.dart'; // لاستيراد الألوان

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
            phone = '0${userDoc['phone']}';
            email = userDoc['email'] as String?;
            birthday = userDoc['birthday'] as String?;
          });
        }
      } else {
        if (kDebugMode) {
          print('150'.tr);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _sendWhatsAppMessage() async {
    final Uri whatsappUrl = Uri.parse(
        "https://wa.me/+962777163292?text=هل ممكن أن احصل على استفسار");
    launchUrl(whatsappUrl);
  }

  PreferredSizeWidget _buildCurvedAppBar(
      BuildContext context, ThemeProvider themeProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipPath(
        clipper: AppBarClipper(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? [Colors.blueGrey, Colors.blueGrey.shade700]
                  : [AppColors.primaryColor, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.blue.withOpacity(0.3),
                offset: const Offset(0, 10),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            title: Text(
              '40'.tr,
              style: GoogleFonts.robotoSlab(
                fontWeight: FontWeight.w600,
                fontSize: 24.0,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // التوجيه إلى صفحة الإعدادات
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen(), // تأكد من وجود صفحة SettingScreen
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: _buildCurvedAppBar(
          context, themeProvider), // استخدم الـ AppBar المنحني
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    '${firstName ?? ''} ${lastName ?? ''}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    email ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountInfoScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(Icons.phone_android, '41'.tr, phone ?? '',
                  isDarkMode: isDarkMode),
              _buildInfoCard(Icons.event_available, '51'.tr, birthday ?? '',
                  isDarkMode: isDarkMode),
              _buildInfoCard(Icons.calendar_today, '42'.tr, '',
                  isDarkMode: isDarkMode, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserAppointmentsPage()),
                );
              }),
              _buildInfoCard(
                  Icons.medication_outlined, 'Search for medicines', '',
                  isDarkMode: isDarkMode, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DrugInfoSearchPage()),
                );
              }),
              const SizedBox(height: 20),
              _buildButtonRow(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value,
      {VoidCallback? onTap, required bool isDarkMode}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading:
            Icon(icon, color: isDarkMode ? Colors.blueAccent : Colors.blue),
        title: Text(title,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildButtonRow(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.black87 : Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _sendWhatsAppMessage,
          icon: const Icon(Icons.help),
          label: Text('44'.tr),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.black87 : Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutAppScreen()),
            );
          },
          icon: const Icon(Icons.info),
          label: Text('45'.tr),
        ),
      ],
    );
  }
}
