import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordEncryptor {
  /// Генерирует MD5-хэш пароля для PostgreSQL
  /// Формат: 'md5' + md5(password + username)
  static String md5PasswordHash(String password, String username) {
    var bytes = utf8.encode(password + username);
    var digest = md5.convert(bytes);
    return 'md5${digest.toString()}';
  }

  /// Генерирует SCRAM-SHA-256 хэш пароля для PostgreSQL
  /// ВНИМАНИЕ: Это упрощенная реализация для демонстрации.
  /// Полная реализация SCRAM требует генерации случайной соли и использования PBKDF2.
  /// Для production используйте встроенные функции PostgreSQL или специализированные библиотеки.
  static String scramSha256PasswordHash(
    String password, {
    String salt = 'default_salt',
    int iterations = 4096,
  }) {
    // Для демонстрации используем простой SHA-256 хэш вместо полного SCRAM
    var passwordBytes = utf8.encode(password);
    var digest = sha256.convert(passwordBytes);
    var saltBytes = utf8.encode(salt);
    var saltDigest = sha256.convert(saltBytes);
    var combined = digest.bytes + saltDigest.bytes;
    var finalDigest = sha256.convert(combined);

    // Упрощенный формат
    var saltBase64 = base64.encode(saltBytes);
    var hashBase64 = base64.encode(finalDigest.bytes);

    return 'SCRAM-SHA-256\$$iterations:$saltBase64\$$hashBase64:simplified';
  }
}
