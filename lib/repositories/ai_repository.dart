import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiRepository {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  AiRepository() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }

  Future<String> generateComment(String content) async {
    try {
      final prompt =
          '以下の日記に対して、共感的で前向きな短いコメント（100文字以内）を返してください。\n\n日記:\n$content';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'コメントを生成できませんでした。';
    } catch (e) {
      // API key missing or error
      print('Gemini API Error: $e');
      return 'AIコメントの生成に失敗しました。APIキーを確認してください。';
    }
  }
}
