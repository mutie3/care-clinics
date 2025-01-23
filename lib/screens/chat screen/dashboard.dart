import 'dart:typed_data';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/gemini_provider.dart';
import '../../constants/theme_dark_mode.dart';
import '../../data/database_helper_chatbot.dart';
import '../home_page.dart';
import 'chat_input.dart';
import 'message_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  // ignore: unused_field
  bool _isLoading = false;

  String cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\*+'), '');
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final geminiProvider =
          Provider.of<GeminiProvider>(context, listen: false);

      setState(() {
        _messages.insert(0, {
          'type': 'text',
          'data': _messageController.text,
          'sender': 'user',
        });
        _messages.insert(0, {
          'type': 'text',
          'data': '...',
          'sender': 'ai',
        });
        _isLoading = true;
      });

      geminiProvider
          .generateContentFromText(prompt: _messageController.text)
          .then((_) {
        setState(() {
          _messages[0] = {
            'type': 'text',
            'data': cleanResponse(
                geminiProvider.response ?? 'No response from AI.'),
            'sender': 'ai',
          };
          _isLoading = false;
        });

        // حفظ الرسائل في قاعدة البيانات
        DatabaseHelper.instance.insertMessage({
          'message': _messageController.text,
          'sender': 'user',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        DatabaseHelper.instance.insertMessage({
          'message': geminiProvider.response ?? 'No response from AI.',
          'sender': 'ai',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      });

      _messageController.clear();
    }
  }

  Future<void> _sendImageMessage(Uint8List imageBytes) async {
    final geminiProvider = Provider.of<GeminiProvider>(context, listen: false);

    // احصل على اللغة الحالية باستخدام GetX
    final currentLocale = Get.locale ??
        const Locale('en'); // إذا لم يتم تحديد اللغة الافتراضية، الإنجليزية.
    final isArabic = currentLocale.languageCode == 'ar';

    // النصوص للرد بناءً على اللغة
    const promptArabic =
        "قم بتحليل هذه الصورة فقط إذا كانت تحتوي على محتوى طبي مثل صور الأشعة السينية، أو صور الرنين المغناطيسي، أو غيرها من الصور الطبية. أما إذا كانت الصورة غير طبية، فالرجاء الرد بـ: 'هذه ليست صورة طبية. يمكنني فقط تحليل الصور الطبية'.";
    const promptEnglish =
        "Analyze this image only if it contains medical content such as X-rays, MRIs, or other medical images. If the image is non-medical, please respond with 'This is not a medical image. I can only analyze medical images.'";

    setState(() {
      _messages
          .insert(0, {'type': 'image', 'data': imageBytes, 'sender': 'user'});
      _messages.insert(0, {
        'type': 'text',
        'data': '...',
        'sender': 'ai',
      });
      _isLoading = true;
    });

    geminiProvider
        .generateContentFromImage(
      prompt: isArabic ? promptArabic : promptEnglish,
      bytes: imageBytes,
    )
        .then((_) {
      setState(() {
        _messages[0] = {
          'type': 'text',
          'data':
              cleanResponse(geminiProvider.response ?? 'No response from AI.'),
          'sender': 'ai',
        };
        _isLoading = false;
      });
    });
  }

  PreferredSizeWidget _buildCurvedAppBar(
      BuildContext context, ThemeProvider themeProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipPath(
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
              'Hakeem AI',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: _buildCurvedAppBar(
          context, themeProvider), // Using the PreferredSizeWidget here
      body: Column(
        children: [
          Expanded(
            child: MessageList(messages: _messages),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0), // رفع مربع الكتابة
            child: ChatInput(
              messageController: _messageController,
              onSendMessage: _sendMessage,
              onSendImage: _sendImageMessage,
            ),
          ),
        ],
      ),
    );
  }
}
