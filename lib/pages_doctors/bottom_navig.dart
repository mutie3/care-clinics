import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CircleNavBar(
          activeIcons: [
            InkWell(
              onTap: () => onTap(0),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 80, // عرض الحاوية لتوسيع مساحة الضغط
                height: 80, // ارتفاع الحاوية لتوسيع مساحة الضغط
                alignment: Alignment.center, // يضمن أن الأيقونة في المنتصف
                child: Icon(
                  Icons.home_filled,
                  size: 30, // حجم الأيقونة
                  color: themeProvider.isDarkMode
                      ? Colors.black
                      : AppColors.primaryColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => onTap(1),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: Icon(
                  Icons.search,
                  size: 30,
                  color: themeProvider.isDarkMode
                      ? Colors.black
                      : AppColors.primaryColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => onTap(2),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: Icon(
                  Icons.chat,
                  size: 30,
                  color: themeProvider.isDarkMode
                      ? Colors.black
                      : AppColors.primaryColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => onTap(3),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: themeProvider.isDarkMode
                      ? Colors.black
                      : AppColors.primaryColor,
                ),
              ),
            ),
          ],
          inactiveIcons: [
            SizedBox(
              width: 80,
              height: 60,
              child: Icon(
                Icons.home_filled,
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(
              width: 80,
              height: 60,
              child: Icon(
                Icons.search,
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: Icon(
                Icons.chat,
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: Icon(
                Icons.person,
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ],
          color: Colors.white,
          circleColor: Colors.white,
          height: 60,
          circleWidth: 60,
          activeIndex: currentIndex,
          onTap: onTap,
          cornerRadius: const BorderRadius.only(
            topLeft: Radius.circular(17),
            topRight: Radius.circular(17),
          ),
          shadowColor:
              themeProvider.isDarkMode ? Colors.grey : AppColors.primaryColor,
          circleShadowColor:
              themeProvider.isDarkMode ? Colors.grey : AppColors.primaryColor,
          elevation: 20,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              themeProvider.isDarkMode ? Colors.black : AppColors.primaryColor,
              themeProvider.isDarkMode ? Colors.grey : AppColors.primaryColor,
            ],
          ),
          circleGradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              themeProvider.isDarkMode ? Colors.black : Colors.white,
              themeProvider.isDarkMode ? Colors.white : AppColors.primaryColor,
            ],
          ),
        );
      },
    );
  }
}
