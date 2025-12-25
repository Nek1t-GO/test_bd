import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/password_encryptor.dart';

void main() {
  group('PasswordEncryptor', () {
    test('MD5 hash generation', () {
      const password = 'password';
      const username = 'user';
      final hash = PasswordEncryptor.md5PasswordHash(password, username);
      expect(hash, startsWith('md5'));
      expect(hash.length, 35); // md5 + 32 hex chars
    });

    test('SCRAM hash generation', () {
      const password = 'password';
      final hash = PasswordEncryptor.scramSha256PasswordHash(password);
      expect(hash, startsWith('SCRAM-SHA-256'));
      expect(hash, contains('\$'));
    });
  });
}
