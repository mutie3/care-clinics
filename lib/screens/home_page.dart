import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors_page.dart';
import '../constants/theme_dark_mode.dart';
import '../pages_doctors/bottom_navig.dart';
import 'clinic.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'search.dart';
import 'chat%20screen/dashboard.dart';

class HomePageSpecializations extends StatefulWidget {
  const HomePageSpecializations({super.key, required this.isGustLogin});
  final bool isGustLogin;

  @override
  HomePageSpecializationsState createState() => HomePageSpecializationsState();
}

class HomePageSpecializationsState extends State<HomePageSpecializations> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<Map<String, dynamic>> getMedicalSpecialties() {
    return [
      {
        "name": '14'.tr,
        "icon": FontAwesomeIcons.listAlt
      }, // أيقونة شاملة لجميع التخصصات
      {
        "name": '15'.tr,
        "icon": FontAwesomeIcons.medkit
      }, // أيقونة لمجموعة أدوات طبية
      {
        "name": '16'.tr,
        "icon": FontAwesomeIcons.userInjured
      }, // أيقونة مريض مصاب
      {"name": '17'.tr, "icon": FontAwesomeIcons.child}, // أيقونة طفل
      {
        "name": '18'.tr,
        "icon": FontAwesomeIcons.venusMars
      }, // أيقونة ولادة وجنس
      {
        "name": '19'.tr,
        "icon": FontAwesomeIcons.handHoldingHeart
      }, // أيقونة للعناية بالبشرة
      {
        "name": '20'.tr,
        "icon": FontAwesomeIcons.heartPulse
      }, // أيقونة نبض القلب
      {"name": '21'.tr, "icon": FontAwesomeIcons.hammer}, // أيقونة جراحة العظام
      {"name": '22'.tr, "icon": FontAwesomeIcons.brain}, // أيقونة الدماغ
      {
        "name": '23'.tr,
        "icon": FontAwesomeIcons.bottleDroplet
      }, // أيقونة هرمون أو غدة
      {
        "name": '3'.tr,
        "icon": FontAwesomeIcons.utensils
      }, // أيقونة غذاء أو معدة
      {"name": '4'.tr, "icon": FontAwesomeIcons.lungs}, // أيقونة الرئتين
      {
        "name": '5'.tr,
        "icon": FontAwesomeIcons.toilet
      }, // أيقونة للحمام أو البول
      {"name": '6'.tr, "icon": FontAwesomeIcons.capsules}, // أيقونة علاج إشعاعي
      {"name": '7'.tr, "icon": FontAwesomeIcons.running}, // أيقونة رياضية
      {"name": '8'.tr, "icon": FontAwesomeIcons.syringe}, // أيقونة حقنة
      {"name": '9'.tr, "icon": FontAwesomeIcons.pills}, // أيقونة أقراص دواء
      {"name": '10'.tr, "icon": FontAwesomeIcons.virus}, // أيقونة فيروس
      {"name": '11'.tr, "icon": FontAwesomeIcons.carrot}, // أيقونة خضار
      {"name": '12'.tr, "icon": FontAwesomeIcons.eye}, // أيقونة عين
      {"name": '13'.tr, "icon": FontAwesomeIcons.headSideCough} // أيقونة رأس
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            print("Back button pressed");
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
              return false; // لا تغلق التطبيق
            }
            return true; // أغلق التطبيق
          },
          child: Scaffold(
            body: Column(
              children: [
                if (_currentIndex == 0)
                  _buildCurvedAppBar(context, themeProvider),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: _buildPageViewChildren(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if ((index == 2 || index == 3) && widget.isGustLogin) {
                  _showLoginPrompt();
                } else {
                  setState(() {
                    _currentIndex = index;
                    _pageController.jumpToPage(index);
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurvedAppBar(BuildContext context, ThemeProvider themeProvider) {
    return ClipPath(
      clipper: AppBarClipper(),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProvider.isDarkMode
                  ? AppColors.textBox
                  : AppColors.primaryColor,
              themeProvider.isDarkMode
                  ? AppColors.textBox.withOpacity(0.7)
                  : AppColors.primaryColor.withOpacity(0.8),
            ],
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
            '2'.tr,
            style: GoogleFonts.robotoSlab(
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor:
              Colors.transparent, // Ensure transparency for gradient
        ),
      ),
    );
  }

  List<Widget> _buildPageViewChildren() {
    return [
      _buildSpecializationsScreen(context),
      const Search(),
      if (!widget.isGustLogin) ...[
        const DashboardScreen(),
        const UserProfileScreen(),
      ],
    ];
  }

  Widget _buildSpecializationsScreen(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemCount: getMedicalSpecialties().length,
      itemBuilder: (context, index) {
        return _buildSpecialtyCard(getMedicalSpecialties()[index], context);
      },
    );
  }

  Widget _buildSpecialtyCard(
      Map<String, dynamic> specialty, BuildContext context) {
    final specialtyName = specialty['name'] ?? '';
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            if (widget.isGustLogin && specialtyName != '14'.tr) {
              _showVisitorMessage(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Clinics(
                    selectedSpecialty:
                        specialtyName == '14'.tr ? '' : specialtyName,
                    isGustLogin: widget.isGustLogin,
                  ),
                ),
              );
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // زاوية أكثر نعومة
            ),
            elevation: 10.0, // زيادة الظل
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : AppColors.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // زيادة padding لجعل البطاقة أكثر اتساعًا
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // زيادة حجم الأيقونة لتكون أكثر وضوحًا
                  FaIcon(
                    specialty['icon'],
                    size: 50, // زيادة الحجم لجعل الأيقونة أكثر بروزًا
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : AppColors.primaryColor,
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        specialtyName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0, // زيادة الحجم قليلاً لجعل النص أكبر
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('125'.tr),
          content: Text('126'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Text('60'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('117'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showVisitorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('168'.tr),
          content: Text('169'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('148'.tr),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 14);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 14);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
