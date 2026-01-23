import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Map<String, dynamic>> extractReminderDetails(String text) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API Key not found');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // Or gpt-4 if available/preferred
          'messages': [
            {
              'role': 'system',
              'content': '''
You are an intelligent assistant that extracts reminder details from voice commands with high accuracy.

**Your task:**
1. Determine the TYPE of reminder (Medicine or General)
2. Extract relevant fields based on the type

**TYPE DETECTION:**
- If the user mentions medicine names (e.g., Panadol, Aspirin, Ibuprofen), pills, tablets, doses, medication, or taking medicine → TYPE: "Medicine"
- Otherwise → TYPE: "General"

**FIELDS TO EXTRACT:**

For ALL reminders:
- type: "Medicine" or "General"
- title: Brief summary of the task
- date: Date in YYYY-MM-DD format. If "today", use "today". If "tomorrow", use "tomorrow". If specific date mentioned, use that format.
- time: Time in HH:mm format (24-hour). Be precise with AM/PM conversion.

For MEDICINE reminders (additional fields):
- medicineName: The exact name of the medicine mentioned
- dose: Dosage information (e.g., "1 tablet", "2 pills", "5ml"). If not mentioned, use "1 tablet"
- duration: How long to take it (e.g., "7 days", "2 weeks"). Leave empty if not mentioned.

**IMPORTANT RULES:**
1. Return ONLY valid JSON, no extra text
2. Be precise with time conversion (10 AM = 10:00, 8 PM = 20:00, 11:40 AM = 11:40)
3. Extract medicine names exactly as spoken
4. If dose is not mentioned for medicine, default to "1 tablet"
5. Always include the "type" field

**EXAMPLES:**

Input: "Remind me to take Panadol at 11:40 AM"
Output: {"type": "Medicine", "title": "Take Panadol", "medicineName": "Panadol", "dose": "1 tablet", "date": "today", "time": "11:40"}

Input: "I need to take 2 tablets of Aspirin tomorrow at 8 PM"
Output: {"type": "Medicine", "title": "Take Aspirin", "medicineName": "Aspirin", "dose": "2 tablets", "date": "tomorrow", "time": "20:00"}

Input: "Remind me to call Mom tomorrow at 10 AM"
Output: {"type": "General", "title": "Call Mom", "date": "tomorrow", "time": "10:00"}

Input: "Take my blood pressure medication at 9:30 AM for 7 days"
Output: {"type": "Medicine", "title": "Take blood pressure medication", "medicineName": "blood pressure medication", "dose": "1 tablet", "duration": "7 days", "date": "today", "time": "09:30"}

Return ONLY the JSON object, nothing else.
''',
            },
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Parse the content as JSON
        // expected content is a JSON string
        try {
          return jsonDecode(content);
        } catch (e) {
          // Fallback if GPT adds extra text (though system prompt says JSON ONLY)
          // Try to find JSON structure in the string
          final startIndex = content.indexOf('{');
          final endIndex = content.lastIndexOf('}');
          if (startIndex != -1 && endIndex != -1) {
            final jsonStr = content.substring(startIndex, endIndex + 1);
            return jsonDecode(jsonStr);
          }
          throw Exception('Failed to parse AI response');
        }
      } else {
        throw Exception('Failed to connect to OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting details: $e');
    }
  }
}
