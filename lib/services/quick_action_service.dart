import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Actions rapides envoyées par le widget Android ou les raccourcis d'icône.
///
/// Chaque action est une simple requête de recherche (`solde`, `internet`,
/// `transfert`, `forfait`) : l'application reste maîtresse du lancement USSD.
class QuickActionService {
  QuickActionService._();

  static const _channel = MethodChannel('com.zoli.app/unione_quick_actions');

  /// Dernière action demandée par le système, consommée par l'accueil.
  static final ValueNotifier<String?> action = ValueNotifier<String?>(null);

  static bool _initialized = false;

  /// Récupère l'action d'un lancement depuis le widget ou un raccourci.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'quickAction' && call.arguments is String) {
        action.value = call.arguments as String;
      }
    });
    try {
      final initial = await _channel.invokeMethod<String>('getInitialAction');
      if (initial != null && initial.isNotEmpty) {
        action.value = initial;
      }
    } on MissingPluginException {
      // Plateforme non Android ou test sans canal natif.
    } on PlatformException {
      // Le widget reste optionnel : l'application démarre normalement.
    }
  }
}
