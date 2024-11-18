import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:provider/provider.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('حول التطبيق'),
            centerTitle: true,
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تطبيق Care Clinic',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'يهدف تطبيق Care Clinic إلى تقديم خدمات الرعاية الصحية بطريقة سهلة ومريحة. يساعد المستخدمين على إدارة مواعيدهم الطبية، الوصول إلى السجلات الطبية، والتواصل مع الأطباء بشكل فعال.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'أهداف التطبيق:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '- تسهيل الوصول إلى الرعاية الصحية.\n'
                    '- إدارة المواعيد بكفاءة.\n'
                    '- الحفاظ على السجلات الطبية بشكل آمن.\n'
                    '- توفير معلومات صحية موثوقة للمستخدمين.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
