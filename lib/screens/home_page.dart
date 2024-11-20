import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  List<Map<String, dynamic>> medicalSpecialties = [
    {
      "name": "ALL",
      "icon": FontAwesomeIcons.listAlt
    }, // أيقونة شاملة لجميع التخصصات
    {
      "name": "General Medicine",
      "icon": FontAwesomeIcons.medkit
    }, // أيقونة لمجموعة أدوات طبية
    {
      "name": "Internal Medicine",
      "icon": FontAwesomeIcons.userInjured
    }, // أيقونة مريض مصاب
    {"name": "Pediatrics", "icon": FontAwesomeIcons.child}, // أيقونة طفل
    {
      "name": "Obstetrics and Gynecology",
      "icon": FontAwesomeIcons.venusMars
    }, // أيقونة ولادة وجنس
    {
      "name": "Dermatology",
      "icon": FontAwesomeIcons.handHoldingHeart
    }, // أيقونة للعناية بالبشرة
    {
      "name": "Cardiology",
      "icon": FontAwesomeIcons.heartPulse
    }, // أيقونة نبض القلب
    {
      "name": "Orthopedic Surgery",
      "icon": FontAwesomeIcons.hammer
    }, // أيقونة جراحة العظام
    {"name": "Psychiatry", "icon": FontAwesomeIcons.brain}, // أيقونة الدماغ
    {
      "name": "Endocrinology",
      "icon": FontAwesomeIcons.bottleDroplet
    }, // أيقونة هرمون أو غدة
    {
      "name": "Gastroenterology",
      "icon": FontAwesomeIcons.utensils
    }, // أيقونة غذاء أو معدة
    {
      "name": "Respiratory Medicine",
      "icon": FontAwesomeIcons.lungs
    }, // أيقونة الرئتين
    {
      "name": "Nephrology and Urology",
      "icon": FontAwesomeIcons.toilet
    }, // أيقونة للحمام أو البول
    {
      "name": "Oncology and Radiotherapy",
      "icon": FontAwesomeIcons.capsules
    }, // أيقونة علاج إشعاعي
    {
      "name": "Sports Medicine",
      "icon": FontAwesomeIcons.running
    }, // أيقونة رياضية
    {"name": "Hematology", "icon": FontAwesomeIcons.syringe}, // أيقونة حقنة
    {"name": "Hepatology", "icon": FontAwesomeIcons.pills}, // أيقونة أقراص دواء
    {
      "name": "Infectious Diseases",
      "icon": FontAwesomeIcons.virus
    }, // أيقونة فيروس
    {
      "name": "Nutrition and Dietetics",
      "icon": FontAwesomeIcons.carrot
    }, // أيقونة خضار
    {"name": "Ophthalmology", "icon": FontAwesomeIcons.eye}, // أيقونة عين
    {
      "name": "ENT (Ear, Nose, and Throat)",
      "icon": FontAwesomeIcons.headSideCough
    } // أيقونة رأس
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
              return false;
            }
            return true;
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
            'Medical Specialties',
            style: GoogleFonts.robotoSlab(
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
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
      itemCount: medicalSpecialties.length,
      itemBuilder: (context, index) {
        return _buildSpecialtyCard(medicalSpecialties[index], context);
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
            if (widget.isGustLogin && specialtyName != "ALL") {
              _showVisitorMessage(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Clinics(
                    selectedSpecialty:
                        specialtyName == "ALL" ? '' : specialtyName,
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
          title: const Text('Login Required'),
          content: const Text('Please log in first to access this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
          title: const Text('Access Restricted'),
          content: const Text(
              'As a guest, you can only access general information. Please log in for more features.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
