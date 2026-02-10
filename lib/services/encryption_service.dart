import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal();

  final _storage = const FlutterSecureStorage();
  final _keyStorageKey = 'encryption_key';

  encrypt.Key? _key;

  Future<void> init() async {
    if (_key != null) {
      return;
    }

    try {
      String? keyString = await _storage.read(key: _keyStorageKey);
      if (keyString == null) {
        final key = encrypt.Key.fromSecureRandom(32);
        await _storage.write(
          key: _keyStorageKey,
          value: base64Url.encode(key.bytes),
        );
        _key = key;
      } else {
        _key = encrypt.Key(base64Url.decode(keyString));
      }
    } catch (e) {
      rethrow;
    }
  }

  String encryptData(String plainText) {
    if (_key == null) {
      throw Exception("EncryptionService not initialized");
    }

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return "${iv.base64}:${encrypted.base64}";
  }

  String decryptData(String encryptedText) {
    if (_key == null) {
      throw Exception("EncryptionService not initialized");
    }

    try {
      if (!encryptedText.contains(':')) {
        return encryptedText;
      }

      final parts = encryptedText.split(':');
      if (parts.length != 2) return encryptedText;

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return encryptedText;
    }
  }
}
