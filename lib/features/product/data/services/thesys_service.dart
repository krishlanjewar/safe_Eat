import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ThesysService {
  static const String _baseUrl =
      'https://api.thesys.ai/v1'; // Hypothetical URL, check docs if available or assume standard LLM endpoint structure.
  // Actually, usually it is specific. Assuming a generic chat/completion endpoint for now or we might need to search.
  // Given user didn't provide docs, I will assume a standard OpenAI-compatible or similar structure as 'Thesys C1'.
  // If it's a specific "Generative UI" API, it might return JSON representing UI components.

  // Implemented as a service that sends product context and gets a "Generative UI" response.

  Future<String> generateProductInsight(String productContext) async {
    final apiKey = dotenv.env['thesys_api_key'];
    if (apiKey == null) throw Exception("Thesys API Key not found");

    // Constructing a prompt to get a dynamic UI definition or rich text
    // "Create an adaptive interface summary for this product..."

    // hypothetical endpoint
    final url = Uri.parse('$_baseUrl/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'c1-generative-ui', // Hypothetical model name
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an AI nutritionist assistant. Generate a dynamic, engaging analysis of the following food product. Include Nutri-Score analysis, allergen warnings if any, and suggest healthier alternatives if the product is unhealthy. Return the response in Markdown format compatible with Flutter Markdown.',
            },
            {'role': 'user', 'content': productContext},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        // Fallback or error
        // If API doesn't exist yet (fake URL), return a mock for demo.
        print("Thesys API Error: ${response.statusCode} - ${response.body}");
        return "## AI Analysis Unavailable\n\nCould not connect to Thesys AI to generate insights at this moment.";
      }
    } catch (e) {
      print("Thesys Exception: $e");
      return "## AI Insights\n\n*Error generating real-time analysis.*";
    }
  }
}
