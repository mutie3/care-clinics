import 'package:care_clinic/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../screens/appointment_confirmation_page.dart';

class VideoPage extends StatefulWidget {
  @override
  VideoPageState createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/done.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // بدء تشغيل الفيديو تلقائيًا
      });

    // إضافة مستمع للتحقق من نهاية الفيديو
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // الانتقال إلى صفحة المواعيد بعد انتهاء الفيديو
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {}); // إزالة المستمع عند التخلص من الفيديو
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // صفحة بيضاء
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(), // إذا كان الفيديو قيد التحميل
      ),
    );
  }
}
