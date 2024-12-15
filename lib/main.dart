import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/localization/local_controllet.dart';
import 'package:care_clinic/localization/locale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'bloc/appointment_bloc.dart';
import 'constants/gemini_provider.dart';
import 'constants/media_provider.dart';
import 'cubit/navigation_cubit.dart';
import 'data/appointment_repository.dart';
import 'screens/login_page.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appointmentRepository = AppointmentRepository();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => NavigationCubit()),
        ChangeNotifierProvider(create: (_) => GeminiProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        BlocProvider(
          create: (context) => AppointmentBloc(appointmentRepository),
        ),
      ],
      child: const CareClink(),
    ),
  );
}

class CareClink extends StatelessWidget {
  const CareClink({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        Get.put(MyLocaleController());
        return GetMaterialApp(
          title: 'Care Clinic',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme.copyWith(
            textTheme: themeProvider.currentTheme.textTheme.copyWith(
              // تخصيص نصوص الجسم
              bodyLarge: TextStyle(
                fontFamily: 'Tajawal',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              bodyMedium: TextStyle(
                fontFamily: 'Tajawal',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),

              // تخصيص نصوص العرض
              displayLarge: TextStyle(
                fontFamily: 'PlayfairDisplay',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              displayMedium: TextStyle(
                fontFamily: 'PlayfairDisplay',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),

              titleMedium: TextStyle(
                fontFamily: 'Tajawal',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              titleSmall: TextStyle(
                fontFamily: 'Tajawal',
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          locale: Get.deviceLocale,
          translations: MyLocale(),
          home: const VideoPlayerScreen(),
        );
      },
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro_logo.mp4')
      ..initialize().then((_) {
        setState(() {}); // تحديث واجهة المستخدم بعد التهيئة
        _controller.play();
        Future.delayed(const Duration(seconds: 2), () {
          // قم بتهيئة صفحة تسجيل الدخول بعد وقت قصير
          precacheImage(AssetImage('images/logo.png'), context);
        });
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      }).catchError((error) {
        print("Error initializing video: $error");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const LoginPage(),
        ),
      ),
    );
  }
}
