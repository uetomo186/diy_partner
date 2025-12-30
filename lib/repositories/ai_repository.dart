import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiRepository {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  AiRepository() {
    print('AiRepository: API Key loaded: ${_apiKey.isNotEmpty}');
    print(
      'AiRepository: API Key starts with: ${_apiKey.length > 5 ? _apiKey.substring(0, 5) : 'TOO_SHORT'}',
    );
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<String> generateComment(String content) async {
    try {
      final prompt =
          '以下の日記に対して、共感的で前向きな短いコメント（100文字以内）を返してください。\n\n日記:\n$content';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'コメントを生成できませんでした。';
    } catch (e, stackTrace) {
      // API key missing or error
      print('Gemini API Error: $e');
      print('Stack Trace: $stackTrace');
      return 'AIコメントの生成に失敗しました。APIキーを確認してください。';
    }
  }
}
