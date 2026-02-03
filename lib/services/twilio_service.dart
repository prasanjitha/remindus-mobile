import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TwilioService {
  final String accountSid = dotenv.env['TWILIO_ACCOUNT_SID']!;
  final String authToken = dotenv.env['TWILIO_AUTH_TOKEN']!;
  final String twilioNumber = dotenv.env['TWILIO_PHONE_NUMBER']!;

  Future<void> sendOTP(String recipientNumber, String otpCode) async {
    final url = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
    );

    String auth =
        'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioNumber.trim(),
          'To': recipientNumber.replaceAll(' ', '').trim(),
          'Body': 'Your OTP is $otpCode',
        },
      );

      if (response.statusCode == 201) {
      } else {}
    } catch (e) {}
  }
}
