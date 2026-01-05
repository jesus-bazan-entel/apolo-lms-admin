
import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrGeneratorService {
  
  // Generates a unique hash based on user ID and email
  // This hash can be used as the content of the QR code
  static String generateUserQrHash(String userId, String email) {
    final String data = '$userId:$email:${DateTime.now().millisecondsSinceEpoch}';
    final List<int> bytes = utf8.encode(data);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Determine if a user needs a new QR code (e.g., if null)
  static bool needsQrCode(String? currentHash) {
    return currentHash == null || currentHash.isEmpty;
  }
}
