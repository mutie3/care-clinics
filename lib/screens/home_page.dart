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
      const Search(),
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
