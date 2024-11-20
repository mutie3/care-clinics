import 'dart:typed_data';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/gemini_provider.dart';
import '../../data/database_helper_chatbot.dart';
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
      prompt:
          'Analyze this image only if it contains medical content such as X-rays, MRIs, or other medical images. If the image is non-medical, please respond with "This is not a medical image. I can only analyze medical images."',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medical_information, color: Colors.white, size: 30),
            SizedBox(width: 8),
            Text(
              'Hakeem AI',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 24,
                letterSpacing: 1, // تباعد الأحرف لجعل النص أكثر عصرية
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor, // خلفية الـ AppBar
      ),
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
