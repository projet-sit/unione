import 'package:flutter/foundation.dart';

/// Configuration du backend distant (catalogue USSD et catalogues de forfaits).
///
/// Les URLs sont fournies au build via `--dart-define` :
/// - `UNIONE_CODES_URL` : arbre USSD (JSON versionné servi en HTTPS).
/// - `UNIONE_CATALOGS_URL` : `GET /v1/catalogs` du backend Node.js.
///
/// Sans URL, l'application fonctionne uniquement avec le JSON embarqué.
class BackendConfig {
  static String codesUrl = String.fromEnvironment('UNIONE_CODES_URL');
  static String catalogsUrl = String.fromEnvironment('UNIONE_CATALOGS_URL');

  /// Timeout court : un backend lent ne doit jamais bloquer l'interface.
  static const Duration timeout = Duration(seconds: 5);

  /// En release, HTTPS est obligatoire. En debug, HTTP reste autorisé pour
  /// tester contre un backend local (`http://localhost:3000`).
  static bool isSecure(Uri uri) {
    if (uri.scheme == 'https') return true;
    return !kReleaseMode && uri.scheme == 'http';
  }

  static Uri? parseUrl(String raw) {
    if (raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || !isSecure(uri)) return null;
    return uri;
  }
}
