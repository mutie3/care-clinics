import 'package:animations/animations.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/patient/regestration_page_Info.dart';
import 'package:care_clinic/screens/doctor_reg/clinic_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RegAsSelect extends StatefulWidget {
  const RegAsSelect({super.key});

  @override
  State<RegAsSelect> createState() => _RegAsSelectState();
}

class _RegAsSelectState extends State<RegAsSelect> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            color: themeProvider.isDarkMode
                ? Colors.grey[900]
                : AppColors.primaryColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '66'.tr,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          OpenContainer(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            closedShape: const CircleBorder(),
                            closedElevation: 0,
                            middleColor: Colors.transparent,
                            closedColor: const Color(0xFF1E88E5),
                            transitionDuration:
                                const Duration(milliseconds: 1200),
                            closedBuilder: (context, action) {
                              return const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('images/doctor.png'),
                              );
                            },
                            openBuilder: (context, action) {
                              return const RegPage();
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '67'.tr,
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 18,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          // pacent
                          OpenContainer(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            closedShape: const CircleBorder(),
                            closedElevation: 0,
                            middleColor: Colors.transparent,
                            closedColor: const Color(0xFF1E88E5),
                            transitionDuration:
                                const Duration(milliseconds: 1200),
                            closedBuilder: (context, action) {
                              return const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('images/patient.png'),
                              );
                            },
                            openBuilder: (context, action) {
                              return const RegistrationPage(); //حط الصفحة تبعتك هون بدل هاي
                            },
                          ),

                          const SizedBox(height: 10),
                          Text(
                            '68'.tr,
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 18,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
