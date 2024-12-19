import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/field_login/email_field.dart';
import 'package:care_clinic/field_login/password_field.dart';
import 'package:care_clinic/field_login/remember_me_field.dart';
import 'package:care_clinic/field_login/sign_up_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blank_page.dart';
import 'doctor_reg/loading_overlay.dart';
import 'home_page.dart';
import 'package:care_clinic/constants/colors_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool rememberMe = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _checkLoginState(); // التحقق من حالة التذكر
    });
  }

  // التحقق من حالة التذكر
  Future<void> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemembered = prefs.getBool('isRemembered') ?? false;

    if (isRemembered) {
      User? user = _auth.currentUser;

      if (user != null) {
        String email = user.email ?? '';

        final clinicSnapshot = await FirebaseFirestore.instance
            .collection('clinics')
            .where('email', isEqualTo: email)
            .get();

        if (clinicSnapshot.docs.isNotEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BlankPage(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePageSpecializations(
                isGustLogin: false,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  // تسجيل الدخول
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay(message: "");
      },
    );

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      final String email = _emailController.text.trim();

      // حفظ حالة "Remember Me" إذا تم اختياره
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRemembered', true);
      }

      final clinicSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .where('email', isEqualTo: email)
          .get();

      if (clinicSnapshot.docs.isNotEmpty) {
        Navigator.of(context).pop(); // إخفاء الـ LoadingOverlay
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BlankPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          Navigator.of(context).pop(); // إخفاء الـ LoadingOverlay
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePageSpecializations(
                isGustLogin: false,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pop(); // إخفاء الـ LoadingOverlay
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not found")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // إخفاء الـ LoadingOverlay
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();

    _passwordController.dispose();
    super.dispose();
  }

  void _guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const HomePageSpecializations(
                isGustLogin: true,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        String logoImage = themeProvider.isDarkMode
            ? 'images/dark-logo.png'
            : 'images/logo.png';

        return Scaffold(
          body: FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                logoImage,
                                height: 200,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        EmailField(controller: _emailController),
                        const SizedBox(height: 20),
                        PasswordField(controller: _passwordController),
                        const SizedBox(height: 10),
                        RememberMeAndForgotPasswordRow(
                          rememberMe: rememberMe, // Pass rememberMe state
                          onRememberMeChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        LoginButtons(
                          onLoginPressed: _login,
                          onGuestLoginPressed: _guestLogin,
                        ),
                        const SizedBox(height: 20),
                        const SignUpText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginButtons extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGuestLoginPressed;

  const LoginButtons({
    super.key,
    required this.onLoginPressed,
    required this.onGuestLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? Colors.grey
                      : AppColors.scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onGuestLoginPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Guest Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
