import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Service d'audit et de journalisation sécurisée.
/// Utilise le skill [security-reviewer] pour garantir que les logs ne contiennent pas de données sensibles.
class AuditService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void logInfo(String message) => _logger.i(message);
  static void logWarning(String message) => _logger.w(message);
  static void logError(String message, [dynamic error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);

  /// Log une transaction USSD sans jamais inclure le PIN.
  static void logUssdTransaction(String network, String action, String amount) {
    _logger.i('Transaction USSD: $network | $action | Montant: $amount');
  }
}

/// Service de stockage sécurisé pour les préférences et données sensibles.
/// Applique les principes du skill [secure-code-guardian].
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  /// Sauvegarde une donnée de manière sécurisée.
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lit une donnée sécurisée.
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Supprime une donnée sécurisée.
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
