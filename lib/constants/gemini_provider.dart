import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/gemini_service.dart';

class GeminiProvider extends ChangeNotifier {
  static GenerativeModel _initModel() {
    final key = dotenv.env['GEMINI_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found');
    }
    return GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
  }

  static final _geminiService = GeminiService(model: _initModel());

  String? response;
  bool isLoading = false;
  List<String> conversationHistory = [];

  String detectLanguage(String input) {
    final englishPattern = RegExp(r'[a-zA-Z]');
    if (englishPattern.hasMatch(input)) {
      return 'en';
    } else {
      return 'ar';
    }
  }

  Future<void> generateContentFromText({
    required String prompt,
  }) async {
    isLoading = true;
    notifyListeners();
    response = null;

    conversationHistory.add(prompt);

    final language = detectLanguage(prompt);

    final healthPrompt = language == 'en'
        ? '''
        You are a medical assistant. You can only answer medical-related questions.
        If the question is not medical, respond with "Sorry, I cannot answer non-medical questions. Please ask a medical-related question."
        Provide helpful answers regarding healthcare, including general advice, preliminary symptom analysis, and recommending appropriate doctors or clinics based on the user's condition. Answer directly and never mention that you are not qualified to provide medical advice.
        Previous conversation: ${conversationHistory.join("\n")}
        Question: $prompt
      '''
        : '''
        أنت مساعد طبي مختص. يمكنك الإجابة فقط على الأسئلة المتعلقة بالمجال الطبي.
        إذا كان السؤال غير طبي، قم بالرد بـ "اعتذر، لا يمكنني الإجابة على أسئلة غير طبية. الرجاء طرح سؤال متعلق بالمجال الطبي."
        قم بتقديم إجابات مفيدة حول الرعاية الصحية تشمل تقديم نصائح عامة وتحليل الأعراض بشكل مبدئي، وترشيح الأطباء أو العيادات المناسبة حسب حالة المستخدم فقط. أجب بشكل مباشر ولا تذكر أنك غير مؤهل لتقديم المشورة الطبية أبدًا.
        المحادثة السابقة: ${conversationHistory.join("\n")}
        السؤال: $prompt
      ''';

    response =
        await _geminiService.generateContentFromText(prompt: healthPrompt);
    isLoading = false;
    notifyListeners();
  }

  Future<void> generateContentFromImage({
    required String prompt,
    required Uint8List bytes,
  }) async {
    isLoading = true;
    notifyListeners();
    response = null;
    final dataPart = DataPart(
      'image/jpeg',
      bytes,
    );

    response = await _geminiService.generateContentFromImage(
      prompt: prompt,
      dataPart: dataPart,
    );

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    response = null;
    isLoading = false;
    conversationHistory.clear();
    notifyListeners();
  }
}
