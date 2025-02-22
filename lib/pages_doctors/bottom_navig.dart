import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../constants/colors_page.dart';
import '../constants/theme_dark_mode.dart';

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
        final isDarkMode = themeProvider.isDarkMode;
        // Use a single color for primaryColor
        final primaryColor = isDarkMode ? Colors.blueGrey : Colors.blueAccent;
        final secondaryColor = isDarkMode ? AppColors.textBox : Colors.white;

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: secondaryColor, // single color here
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : secondaryColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: primaryColor,
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIcon(index),
                        size: isActive ? 30 : 26,
                        color: isActive
                            ? Colors.white
                            : isDarkMode
                                ? Colors.grey
                                : Colors.black54,
                      ),
                      const SizedBox(height: 4),
                      if (isActive)
                        Text(
                          _getLabel(index),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.search_rounded;
      case 2:
        return Icons.chat_bubble_rounded;
      case 3:
        return Icons.person_rounded;
      default:
        return Icons.home;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return '144'.tr;
      case 1:
        return '145'.tr;
      case 2:
        return '146'.tr;
      case 3:
        return '147'.tr;
      default:
        return '';
    }
  }
}
