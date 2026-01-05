import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiRepository {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  AiRepository() {
    print('AiRepository (OpenAI): API Key loaded: ${_apiKey.isNotEmpty}');
    print(
      'AiRepository (OpenAI): API Key starts with: ${_apiKey.length > 5 ? _apiKey.substring(0, 5) : 'TOO_SHORT'}',
    );
  }

  Future<String> generateComment(String content) async {
    if (_apiKey.isEmpty) {
      return 'APIキー（OPENAI_API_KEY）が設定されていません。';
    }

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // Or 'gpt-4o' if available
          'messages': [
            {
              'role': 'system',
              'content':
                  'あなたは共感的で前向きなパートナーです。ユーザーの日記に対して、短く（100文字以内）励ましや共感のコメントを返してください。日本語で答えてください。',
            },
            {'role': 'user', 'content': content},
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else if (response.statusCode == 429) {
        print('OpenAI API Error: 429 Quota Exceeded');
        return 'エラー: OpenAIの利用枠を超過しました(429)。\nクレジット残高やプランを確認してください。';
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return 'AIコメントの生成に失敗しました。(Status: ${response.statusCode})';
      }
    } catch (e) {
      print('OpenAI Exception: $e');
      return 'エラーが発生しました: $e';
    }
  }
}
