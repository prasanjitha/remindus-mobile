import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';

class ElevenLabsService {
  static final String? _apiKey = dotenv.env['ELEVENLABS_API_KEY'];
  static final String? _voiceId = dotenv.env['ELEVENLABS_VOICE_ID'];

  // Default voice ID if not set (Rachel voice)
  static const String _defaultVoiceId = '21m00Tcm4TlvDq8ikWAM';

  static Future<void> speakText(String text) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return;
    }

    final voiceId = _voiceId ?? _defaultVoiceId;

    try {
      // ElevenLabs Text-to-Speech API endpoint
      final url = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$voiceId',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey!,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        // Play the audio
        final player = AudioPlayer();
        await player.play(BytesSource(response.bodyBytes));

        // Wait for audio to finish
        await player.onPlayerComplete.first;
        await player.dispose();
      } else {}
    } catch (e) {}
  }

  // Optional: Stream audio for faster response
  static Future<void> speakTextStream(String text) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return;
    }

    final voiceId = _voiceId ?? _defaultVoiceId;

    try {
      final url = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$voiceId/stream',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey!,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        final player = AudioPlayer();
        await player.play(BytesSource(response.bodyBytes));
        await player.onPlayerComplete.first;
        await player.dispose();
      } else {}
    } catch (e) {}
  }
}
