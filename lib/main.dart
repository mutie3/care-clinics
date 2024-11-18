import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'bloc/appointment_bloc.dart';
import 'constants/gemini_provider.dart';
import 'constants/media_provider.dart';
import 'cubit/navigation_cubit.dart';
import 'screens/login_page.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => AppointmentBloc()),
        ChangeNotifierProvider(create: (_) => GeminiProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
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
        return MaterialApp(
          title: 'Care Clinic',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
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
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro_logo.mp4')
      ..initialize().then((_) {
        setState(() {}); // لتحديث واجهة المستخدم بعد تهيئة الفيديو
        _controller.play();
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      }).catchError((error) {
        print("Error initializing video: $error");
        // إذا حدث خطأ، الانتقال إلى صفحة تسجيل الدخول مباشرة
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
