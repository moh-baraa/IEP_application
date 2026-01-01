import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
// === encryption key, 32 ch for more security ===
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); 
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // === string into encrypt ===
  static String encryptData(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  // === encrypt into string ===
  static String decryptData(String encryptedText) {
    return _encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: _iv);
  }
}