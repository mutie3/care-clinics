import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/accont_info_screen.dart';
import 'package:care_clinic/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  // final Function(Locale) onLanguageChange;
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = false;
  bool isFingerprintEnabled = false; // متغير لتخزين حالة البصمة
  final LocalAuthentication _localAuth =
      LocalAuthentication(); // إنشاء الكائن الخاص بالبصمة
// تحميل حالة البصمة من SharedPreferences
  Future<void> _loadFingerprintPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    });
  }

  // حفظ حالة تفعيل البصمة في SharedPreferences
  Future<void> _saveFingerprintPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode
            ? AppColors.textBox
            : AppColors.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // عنوان القسم
          _buildSectionTitle('إعدادات الحساب'),
          _buildListTile(
            title: 'معلومات الحساب',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AccountInfoScreen()),
              );
            },
          ),
          _buildListTile(
            title: 'تغيير البريد الإلكتروني',
            onTap: () {
              // يمكنك إضافة ما تريده عند الضغط هنا
            },
          ),
          _buildListTile(
            title: 'تغيير كلمة المرور',
            onTap: () {
              // يمكنك إضافة ما تريده عند الضغط هنا
            },
          ),
          _buildListTile(
            title: 'الإشعارات',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            onTap: () {
              // يمكنك إضافة ما تريده عند الضغط هنا
            },
          ),

          _buildSectionTitle('اللغة و الوضع'),
          _buildListTile(
            title: 'اللغة',
            subtitle: 'اللغة',
            onTap: () {},
          ),
          _buildListTile(
            title: 'الوضع',
            subtitle: themeProvider.isDarkMode ? 'داكن' : 'فاتح',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                // تحديث حالة الوضع الداكن
                themeProvider.toggleTheme(value);
              },
            ),
          ),
          _buildListTile(
            title: 'تفعيل البصمة',
            subtitle: isFingerprintEnabled ? 'مفعل' : 'غير مفعل',
            trailing: Switch(
              value: isFingerprintEnabled,
              onChanged: (value) async {
                // التحقق إذا كانت البصمة مدعومة
                bool canAuthenticate = await _localAuth.canCheckBiometrics;
                if (canAuthenticate) {
                  // إذا كانت البصمة مدعومة، نطلب التحقق منها
                  bool authenticated = await _localAuth.authenticate(
                    localizedReason: 'يرجى التحقق باستخدام البصمة',
                    options: const AuthenticationOptions(stickyAuth: true),
                  );

                  // إذا تم التحقق من البصمة بنجاح، نغير حالة تفعيل البصمة
                  if (authenticated) {
                    setState(() {
                      isFingerprintEnabled = value;
                    });
                    // حفظ حالة تفعيل البصمة
                    await _saveFingerprintPreference(value);
                  } else {
                    // إذا فشل التحقق من البصمة، نعرض رسالة للمستخدم
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('فشل التحقق باستخدام البصمة')),
                    );
                  }
                } else {
                  // إذا كانت البصمة غير مدعومة
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('البصمة غير مدعومة في هذا الجهاز')),
                  );
                }
              },
            ),
          ),

          // عنصر تسجيل الخروج
          _buildListTile(
            title: 'تسجيل الخروج',
            leading: const Icon(
              Icons.logout,
              color: Colors.red, // تغيير اللون لجعل الأيقونة واضحة
              size: 28, // زيادة حجم الأيقونة
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            showTrailing: false, // عدم عرض السهم لهذا العنصر
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    Icon? leading, // إضافة وسيط للأيقونة
    VoidCallback? onTap,
    bool showTrailing = true, // وسيط للتحكم في عرض السهم
  }) {
    return Column(
      children: [
        ListTile(
          leading: leading, // استخدام الأيقونة إذا كانت موجودة
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: showTrailing
              ? (trailing ?? const Icon(Icons.arrow_forward_ios))
              : null,
          onTap: onTap,
        ),
        const Divider(height: 10),
      ],
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
}
