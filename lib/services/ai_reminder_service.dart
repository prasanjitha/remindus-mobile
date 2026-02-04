import 'dart:convert';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:remindus/models/base_reminder_model.dart';

class AiReminderService {
  static const String _openaiUrl = 'https://api.openai.com/v1/chat/completions';

  // Function to scan a prescription/text and getting a GPT response
  Future<List<ReminderModel>> extractRemindersFromAi({
    String? imagePath,
  }) async {
    if (imagePath == null) return [];

    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API Key not found in .env');
      }

      // Convert image to base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Get current date for context
      final String currentDate = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''
You are an expert medical assistant. Your task is to extract medical and meeting reminders from images (prescriptions, notes, etc.).

IMPORTANT: Today's date is $currentDate. If the text mentions relative dates like "today", "tomorrow", or a specific day of the week, convert them to absolute dates in YYYY-MM-DD format based on today's date ($currentDate).

For each reminder found, you MUST determine its type: "medicine" or "meeting". This "type" field is MANDATORY for every object in the list.

If type is "medicine", extract:
- type: "medicine" (MANDATORY)
- title: A summary (e.g., "Panadol for Fever")
- medicinename: The name of the medicine
- Dose: The dosage (e.g., "1 tablet", "5ml")
- Duration: How long to take it (e.g., "1 week", "until finished")
- start_date: Starting date in YYYY-MM-DD
- when_to_take: A list containing one or more of ["Morning", "Afternoon", "Evening", "Night"]
- Doses: A list of times in "HH:mm AM/PM" format corresponding to when_to_take

If type is "meeting" or other, extract:
- type: "meeting" (MANDATORY)
- title: Summary of the meeting/task
- date: Date in YYYY-MM-DD
- Time: Time in "HH:mm AM/PM" format

Return ONLY a JSON list of objects. Every object MUST have the "type" field.
''',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Extract reminders from this prescription/image.',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': "data:image/jpeg;base64,$base64Image"},
                },
              ],
            },
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Clean content if GPT adds markdown formatting
        if (content.contains('```')) {
          content = content.replaceAll(RegExp(r'```json|```'), '').trim();
        }

        final List<dynamic> jsonList = jsonDecode(content);

        return jsonList.map((e) => _mapJsonToReminder(e)).toList();
      } else {
        throw Exception('Failed to process image with AI');
      }
    } catch (e) {
      rethrow;
    }
  }

  ReminderModel _mapJsonToReminder(Map<String, dynamic> json) {
    String type = json['type'] ?? 'other';
    // Capitalize first letter, lowercase rest for consistency
    type = _capitalizeType(type);

    if (type == 'Medicine') {
      DateTime? startDate;
      if (json['start_date'] != null) {
        try {
          startDate = DateTime.parse(json['start_date']);
        } catch (e) {
          startDate = DateTime.now();
        }
      }

      List<dynamic> whenToTake = json['when_to_take'] ?? [];

      return ReminderModel(
        title: json['title'] ?? '',
        type: type,
        time: json['Doses'] != null && (json['Doses'] as List).isNotEmpty
            ? (json['Doses'] as List).first
            : '09:00 AM', // Default or first dose
        medicineName: json['medicinename'],
        dose: json['Dose'],
        duration: json['Duration'],
        date: startDate != null ? Timestamp.fromDate(startDate) : null,
        whenToTake: List<String>.from(whenToTake),
        schedule: (json['Doses'] as List<dynamic>?)
            ?.map((e) => {'time': e})
            .toList(),
        isRead: false,
      );
    } else {
      // type is meeting or other
      DateTime? meetingDate;
      if (json['date'] != null) {
        try {
          meetingDate = DateTime.parse(json['date']);
        } catch (e) {
          meetingDate = DateTime.now();
        }
      }

      return ReminderModel(
        title:
            json['title'] ?? (type == 'Meeting' ? 'Meeting' : 'New Reminder'),
        type: type,
        time: json['Time'] ?? '09:00 AM',
        date: meetingDate != null ? Timestamp.fromDate(meetingDate) : null,
        isRead: false,
      );
    }
  }

  String _capitalizeType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }
}
