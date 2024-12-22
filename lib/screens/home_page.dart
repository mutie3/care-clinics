import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors_page.dart';
import '../constants/theme_dark_mode.dart';
import '../pages_doctors/bottom_navig.dart';
import '../widgets/advertisements_board.dart';
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
  final List<Map<String, String>> advertisements = [
    {
      'title': 'عن التطبيق',
      'description':
          'تطبيقنا يتيح لك سهولة البحث عن العيادات الطبية، عرض التفاصيل، وحجز المواعيد بكل سهولة.',
      'image': 'images/logo.png', // تأكد من وجود الصورة
    },
    {
      'title': 'الشات بوت الطبي',
      'description':
          'تواصل مع الشات بوت الخاص بنا للإجابة على استفساراتك الصحية بشكل فوري وموثوق.',
      'image': 'images/chat.png', // تأكد من وجود الصورة
    },
    {
      'title': 'موسوعة الأدوية',
      'description':
          'اكتشف معلومات شاملة عن الأدوية، الجرعات، والتفاعلات الدوائية في موسوعتنا الطبية.',
      'image': 'images/med.png', // تأكد من وجود الصورة
    },
  ];

  List<Map<String, dynamic>> getMedicalSpecialties() {
    return [
      {
        "name": '14'.tr,
        "icon": FontAwesomeIcons.hospitalUser
      }, // أيقونة شاملة لجميع التخصصات
      {
        "name": '15'.tr,
        "icon": FontAwesomeIcons.kitMedical
      }, // أيقونة الإسعافات الأولية
      {
        "name": '16'.tr,
        "icon": FontAwesomeIcons.userInjured
      }, // أيقونة إصابات المرضى
      {"name": '17'.tr, "icon": FontAwesomeIcons.baby}, // أيقونة طب الأطفال
      {
        "name": '18'.tr,
        "icon": FontAwesomeIcons.dna
      }, // أيقونة الوراثة والعلوم الحيوية
      {
        "name": '19'.tr,
        "icon": FontAwesomeIcons.handshakeAngle
      }, // أيقونة الدعم والرعاية
      {
        "name": '20'.tr,
        "icon": FontAwesomeIcons.heartPulse
      }, // أيقونة أمراض القلب
      {"name": '21'.tr, "icon": FontAwesomeIcons.bone}, // أيقونة جراحة العظام
      {"name": '22'.tr, "icon": FontAwesomeIcons.brain}, // أيقونة طب الأعصاب
      {
        "name": '23'.tr,
        "icon": FontAwesomeIcons.flask
      }, // أيقونة التحاليل والمختبرات
      {
        "name": '3'.tr,
        "icon": FontAwesomeIcons.utensils
      }, // أيقونة طب الجهاز الهضمي
      {"name": '4'.tr, "icon": FontAwesomeIcons.lungs}, // أيقونة أمراض الرئة
      {
        "name": '5'.tr,
        "icon": FontAwesomeIcons.toiletPaper
      }, // أيقونة أمراض المسالك البولية
      {
        "name": '6'.tr,
        "icon": FontAwesomeIcons.radiation
      }, // أيقونة العلاج الإشعاعي
      {
        "name": '7'.tr,
        "icon": FontAwesomeIcons.personRunning
      }, // أيقونة الطب الرياضي
      {
        "name": '8'.tr,
        "icon": FontAwesomeIcons.syringe
      }, // أيقونة الحقن والعلاجات
      {"name": '9'.tr, "icon": FontAwesomeIcons.pills}, // أيقونة الأدوية
      {
        "name": '10'.tr,
        "icon": FontAwesomeIcons.virus
      }, // أيقونة الأمراض المعدية
      {"name": '11'.tr, "icon": FontAwesomeIcons.carrot}, // أيقونة التغذية
      {"name": '12'.tr, "icon": FontAwesomeIcons.eye}, // أيقونة طب العيون
      {
        "name": '13'.tr,
        "icon": FontAwesomeIcons.headSideCough
      } // أيقونة طب الجهاز التنفسي
    ];
  }

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
            colors: themeProvider.isDarkMode
                ? [Colors.blueGrey, Colors.blueGrey.shade700]
                : [AppColors.primaryColor, Colors.lightBlueAccent],
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
      Search(
        isGustLogin: widget.isGustLogin,
      ),
      if (!widget.isGustLogin) ...[
        const DashboardScreen(),
        const UserProfileScreen(),
      ],
    ];
  }

  Widget _buildSpecializationsScreen(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // لوحة الإعلانات كـ Sliver
        SliverToBoxAdapter(
          child: AdvertisementsBoard(advertisements: advertisements),
        ),

        // شبكة التخصصات كـ SliverGrid
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildSpecialtyCard(
                    getMedicalSpecialties()[index], context);
              },
              childCount: getMedicalSpecialties().length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyCard(
      Map<String, dynamic> specialty, BuildContext context) {
    final specialtyName = specialty['name'] ?? '';

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final cardColor =
            isDarkMode ? Colors.grey[900] : AppColors.scaffoldBackgroundColor;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final borderColor = isDarkMode
            ? Colors.blueGrey
            : AppColors.primaryColor.withOpacity(0.2);

        return GestureDetector(
          onTap: () {
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
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(
                color: borderColor,
                width: 2.0,
              ),
            ),
            elevation: 10.0,
            shadowColor: isDarkMode
                ? Colors.black54
                : Colors.grey.withOpacity(0.3), // Subtle shadow
            color: cardColor,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blueGrey.withOpacity(0.2)
                          : AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: FaIcon(
                      specialty['icon'],
                      size: 60.0, // Large icon for emphasis
                      color: isDarkMode
                          ? Colors.lightBlueAccent
                          : AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Text(
                    specialtyName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 50.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.lightBlueAccent
                          : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(1.5),
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          elevation: 16.0, // Adding shadow for elevation
          backgroundColor: Colors.white, // Background color of the dialog
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '125'.tr,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '126'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        backgroundColor:
                            Colors.blueAccent, // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12.0), // Rounded corners
                        ),
                      ),
                      child: Text(
                        '60'.tr,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        backgroundColor:
                            Colors.grey[300], // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12.0), // Rounded corners
                        ),
                      ),
                      child: Text(
                        '117'.tr,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
