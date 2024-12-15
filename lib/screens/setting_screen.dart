import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/accont_info_screen.dart';
import 'package:care_clinic/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '80'.tr,
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
                  : [AppColors.primaryColor, Colors.lightBlueAccent],
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('24'.tr),
          _buildCustomTile(
            title: '25'.tr,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AccountInfoScreen()),
              );
            },
          ),
          _buildCustomTile(
            title: '26'.tr,
            onTap: () {},
          ),
          _buildCustomTile(
            title: '27'.tr,
            onTap: () {},
          ),
          _buildCustomTile(
            title: '28'.tr,
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),
          _buildSectionTitle('29'.tr),
          _buildCustomTile(
            title: '30'.tr,
            subtitle: '178'.tr,
            onTap: () {},
          ),
          _buildThemeListTile(themeProvider),
          _buildCustomTile(
            title: '32'.tr,
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: 28,
            ),
            onTap: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('179'.tr);
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              } catch (e) {
                print('Error during logout: $e');
              }
            },
            showTrailing: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    Icon? leading,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20.0), // تعديل الحدود
        boxShadow: [
          if (!themeProvider.isDarkMode)
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // تحسين الظل
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600]),
              )
            : null,
        trailing: showTrailing
            ? (trailing ?? const Icon(Icons.arrow_forward_ios))
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThemeListTile(ThemeProvider themeProvider) {
    return _buildCustomTile(
      title: '31'.tr,
      subtitle: themeProvider.isDarkMode ? '82'.tr : '81'.tr,
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color:
            themeProvider.isDarkMode ? Colors.orangeAccent : Colors.blueAccent,
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
        activeColor: Colors.orangeAccent,
        inactiveThumbColor: Colors.blueAccent,
      ),
    );
  }
}
