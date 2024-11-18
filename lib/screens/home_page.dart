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
    {"name": "ALL", "icon": FontAwesomeIcons.borderAll},
    {"name": "General Medicine / Family Medicine", "icon": FontAwesomeIcons.userMd},
    {"name": "Internal Medicine", "icon": FontAwesomeIcons.stethoscope},
    {"name": "Pediatrics", "icon": FontAwesomeIcons.baby},
    {"name": "Obstetrics and Gynecology", "icon": FontAwesomeIcons.venus},
    {"name": "Dermatology", "icon": FontAwesomeIcons.handHoldingMedical},
    {"name": "Cardiology", "icon": FontAwesomeIcons.heartbeat},
    {"name": "Orthopedic Surgery", "icon": FontAwesomeIcons.bone},
    {"name": "Psychiatry", "icon": FontAwesomeIcons.brain},
    {"name": "Endocrinology", "icon": FontAwesomeIcons.vial},
    {"name": "Gastroenterology", "icon": FontAwesomeIcons.userInjured},
    {"name": "Respiratory Medicine", "icon": FontAwesomeIcons.lungs},
    {"name": "Nephrology and Urology", "icon": FontAwesomeIcons.toilet},
    {"name": "Oncology and Radiotherapy", "icon": FontAwesomeIcons.dna},
    {"name": "Sports Medicine", "icon": FontAwesomeIcons.running},
    {"name": "Hematology", "icon": FontAwesomeIcons.syringe},
    {"name": "Hepatology", "icon": FontAwesomeIcons.prescriptionBottle},
    {"name": "Infectious Diseases", "icon": FontAwesomeIcons.virus},
    {"name": "Nutrition and Dietetics", "icon": FontAwesomeIcons.appleAlt},
    {"name": "Ophthalmology", "icon": FontAwesomeIcons.eye},
    {"name": "ENT (Ear, Nose, and Throat)", "icon": FontAwesomeIcons.headSideMask},
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
                if (_currentIndex == 0) _buildCurvedAppBar(context, themeProvider),
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
        height: 120, // جعل الحاوية أقل ارتفاعًا ليكون الانحناء أصغر
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProvider.isDarkMode ? AppColors.textBox : AppColors.primaryColor,
              themeProvider.isDarkMode ? AppColors.textBox : AppColors.primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.5),
              offset: const Offset(0, 8),
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
        child: AppBar(
          title: Text(
            'Medical Specialties',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20.0, // تقليل حجم النص ليكون أصغر
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

  Widget _buildSpecialtyCard(Map<String, dynamic> specialty, BuildContext context) {
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
                    selectedSpecialty: specialtyName == "ALL" ? '' : specialtyName,
                    isGustLogin: widget.isGustLogin,
                  ),
                ),
              );
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 6.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : AppColors.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // تقليل الارتفاع
                  FaIcon(
                    specialty['icon'],
                    size: 40, // جعل الأيقونة أصغر قليلاً
                    color: themeProvider.isDarkMode
                        ? Colors.black
                        : AppColors.primaryColor,
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        specialtyName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0, // تقليل حجم النص ليكون أصغر
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
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
                Navigator.of(context).pop(); // Close the dialog
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
