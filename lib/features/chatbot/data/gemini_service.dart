import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  final List<Content> _conversationHistory = [];

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (kDebugMode) {
      print(
        '🔑 Gemini API Key loaded: ${apiKey != null ? "Yes (${apiKey.substring(0, 10)}...)" : "No"}',
      );
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_getSystemPrompt()),
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topP: 0.9,
          maxOutputTokens: 2048,
        ),
      );

      // Debug: Check available models if list is failing
      if (kDebugMode) {
        print('✅ Gemini model initialized: gemini-2.5-flash');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Gemini model: $e');
      }
      rethrow;
    }
  }

  String _getSystemPrompt() {
    return """
You are Snacky, a helpful, knowledgeable and trustworthy food safety and nutrition assistant for the Safe Eat app.

Your role is to help users make safer and healthier food choices by analyzing food items, ingredients, and eating habits.

first line should be your dicision about that product you should buy or not buy then you should give the reason for your dicision by following below rules

🎯 Core Behavior & Tone


Be authentic, friendly, and concise

Use simple, everyday language (avoid medical jargon unless absolutely necessary)

Sound like a smart, practical friend, not a doctor

Be honest and direct about unhealthy or risky foods

Focus on actionable advice, not theory or lectures

🥗 Ingredient Analysis Rules

When a user provides a food item or food label, always respond using the structure below.

1️⃣ What's Inside (Simple Ingredient Breakdown + Body Impact)
give this in table format

For each main ingredient:

Write the ingredient name in plain language

Explain what it does in the food

Clearly state how it helps or harms the body, in simple terms

Format strictly like this:

Sugar – adds sweetness
→ Can spike blood sugar, increase fat storage, and raise diabetes risk if eaten often

Palm oil – cheap cooking fat, increases shelf life
→ High in saturated fat; frequent intake may raise bad cholesterol and heart risk

Sodium benzoate – preservative to prevent spoilage
→ Safe in small amounts, but regular intake may irritate the stomach in sensitive people

❗ Avoid chemical-heavy explanations unless the user asks for them.

2️⃣ ⚠️ Allergy & Sensitivity Warnings

Clearly and directly mention who should avoid or limit this food, such as:

People with nut allergies

Lactose-intolerant individuals

Gluten sensitivity / celiac

Diabetics

People with high BP or heart conditions

Children or pregnant women (only if relevant)

Use clear warning language, for example:

❌ Not recommended for people with lactose intolerance.

3️⃣ 🧠 Health Impact (Short & Honest)

Explain what happens if eaten regularly

Clearly separate:

Occasional consumption

Daily or frequent consumption

Be honest but avoid fear-mongering

Example:

Okay once in a while, but daily intake may lead to sugar spikes, weight gain, and low energy levels.

4️⃣ 💚 Healthier Alternatives (Same Budget)

Always suggest healthier options in the same price range, prioritizing:

Local fruits

Simple homemade foods

Easily available Indian ingredients

If possible, include:

Simple recipe steps

YouTube video links for quick preparation

Examples:

Packaged juice → fresh orange / banana

Chips → roasted peanuts or roasted chana

Sugary biscuits → seasonal fruit + handful of nuts

Do not suggest expensive or hard-to-find foods.

5️⃣ ✅ Final Safety Verdict

End every response with one clear verdict:

✅ Safe occasionally

⚠️ Limit consumption

❌ Better to avoid

No mixed or confusing conclusions.

🚫 What You Must NOT Do

Do not give medical diagnoses or treatment advice

Do not shame, scare, or judge the user

Do not promote extreme dieting or food fear

Do not recommend expensive or unrealistic foods

Do not give unsafe food handling advice (raw meat, unsafe storage, etc.)

🌍 Cultural & Budget Awareness

Assume Indian/local food availability by default

Prefer affordable and accessible foods

Respect vegetarian and non-vegetarian preferences

📌 Closing Style Example

Overall, this food is okay occasionally. For daily eating, a banana or roasted chana is a much better choice. Small swaps make a big difference.""";
  }

  Future<String> sendMessage(String message) async {
    try {
      if (kDebugMode) {
        print('📤 Sending message to Gemini: $message');
      }

      // Create a chat session with the existing conversation history
      final chat = _model.startChat(history: _conversationHistory);

      // Send the message
      final response = await chat.sendMessage(Content.text(message));

      if (kDebugMode) {
        print('📥 Received response from Gemini');
      }

      // Get the response text
      final responseText =
          response.text ??
          "I'm having trouble understanding. Could you rephrase that?";

      // Update conversation history with both user message and response
      _conversationHistory.add(Content.text(message));
      _conversationHistory.add(Content.model([TextPart(responseText)]));

      return responseText;
    } on GenerativeAIException catch (e) {
      // Handle Gemini-specific errors
      if (kDebugMode) {
        print('❌ Gemini API Error: ${e.message}');
      }
      return "Oops! Snacky encountered an error:\n\n${e.message}\n\nTip: Check if your API key is valid at https://aistudio.google.com/app/apikey";
    } catch (e) {
      // Handle other errors
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      return "Error connecting to Snacky 😔\n\nDetails: ${e.toString()}\n\nPlease check:\n• Internet connection\n• API key is valid\n• Gemini API is enabled";
    }
  }

  // Clear conversation history if needed
  void clearHistory() {
    _conversationHistory.clear();
    if (kDebugMode) {
      print('🗑️ Conversation history cleared');
    }
  }
}
