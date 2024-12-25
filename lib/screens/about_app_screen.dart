import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '45'.tr,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeProvider.isDarkMode
                      ? [Colors.blueGrey, Colors.blueGrey.shade800]
                      : [AppColors.primaryColor, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            elevation: 8,
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '112'.tr,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '111'.tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '113'.tr,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.scaffoldBackgroundColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '114'.tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54),
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
