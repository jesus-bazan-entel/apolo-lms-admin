import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class QrGeneratorService {
  /// Genera una clave de acceso segura de 12 caracteres
  /// Esta clave se usa como contraseña para Firebase Auth
  static String generateAccessKey() {
    const chars = 'AaBbCcDdEeFfGgHhJjKkMmNnPpQqRrSsTtUuVvWwXxYyZz23456789';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Genera el contenido del QR en formato JSON
  /// El QR contiene: {"e":"email","k":"accessKey"}
  /// Este formato permite login directo desde la app
  static String generateQrContent(String email, String accessKey) {
    final Map<String, String> data = {
      'e': email,
      'k': accessKey,
    };
    return json.encode(data);
  }

  /// Genera un hash único basado en userId y email (formato legacy)
  /// @deprecated Usar generateAccessKey() y generateQrContent() en su lugar
  static String generateUserQrHash(String userId, String email) {
    final String data = '$userId:$email:${DateTime.now().millisecondsSinceEpoch}';
    final List<int> bytes = utf8.encode(data);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Determina si un usuario necesita un nuevo código QR
  static bool needsQrCode(String? currentHash) {
    return currentHash == null || currentHash.isEmpty;
  }

  /// Parsea el contenido del QR y extrae los datos
  static Map<String, String>? parseQrContent(String content) {
    try {
      final Map<String, dynamic> data = json.decode(content);
      return {
        'email': data['e'] ?? data['email'] ?? '',
        'key': data['k'] ?? data['key'] ?? '',
      };
    } catch (_) {
      // Formato legacy - solo el hash
      return {'key': content};
    }
  }
}
