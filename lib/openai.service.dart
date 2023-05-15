import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jarvis/secrets.dart';

class OpenAIService {
  List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content":
                    "Does this message want to generate an AI picture, image, art or anything similar? $prompt . simply answer with a yes or no."
              }
            ]
          }));

      // ignore: avoid_print
      print(res.body);

      if (res.statusCode == 200) {
        // ignore: avoid_print
        print("yay!!!");
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim().toLowerCase();
        switch (content) {
          case 'yes':
          case 'yes.':
            final res = await dalleAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}));

      // ignore: avoid_print
      print(res.body);

      if (res.statusCode == 200) {
        // ignore: avoid_print
        print("yay!!!");
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim().toLowerCase();
        messages.add({'role': 'assistant', 'content': content});

        return content;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dalleAPI(String prompt) async {
    return 'DALL-E';
  }
}
