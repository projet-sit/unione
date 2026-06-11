import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'security_service.dart';
import 'history_service.dart';
import '../models/history_item.dart';
import 'package:local_auth/local_auth.dart';

/// Service USSD optimisé et sécurisé.
class UssdService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final HistoryService _historyService = HistoryService();

  /// Vérifie l'identité de l'utilisateur avant une action sensible.
  static Future<bool> verifyIdentity() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // On laisse passer si le device n'est pas sécurisé

      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour valider la transaction',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      AuditService.logError('Erreur d\'authentification locale', e);
      return false;
    }
  }

  /// Lance un code USSD de manière sécurisée.
  static Future<bool> launchUssd(BuildContext context, String code, {String? title, String? network}) async {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      AuditService.logWarning('Tentative de lancement d\'un code USSD vide.');
      _showFailure(context, 'Code USSD invalide.');
      return false;
    }

    final isUssd = trimmedCode.startsWith('*') && trimmedCode.endsWith('#');
    final isPlainNumber = RegExp(r'^\d+$').hasMatch(trimmedCode);
    
    if (!isUssd && !isPlainNumber) {
      AuditService.logWarning('Format invalide : $trimmedCode');
      _showFailure(context, 'Format non supporté.');
      return false;
    }

    try {
      // Masquage partiel dans les logs pour la sécurité
      final displayCode = trimmedCode.length > 4 
          ? '${trimmedCode.substring(0, 3)}...#' 
          : trimmedCode;
      AuditService.logInfo('Lancement USSD : $displayCode');
      
      final launched = await FlutterPhoneDirectCaller.callNumber(trimmedCode);

      if (launched == true) {
        // Sécurité : Ne jamais enregistrer le code USSD brut s'il peut contenir un PIN
        final historyDescription = trimmedCode.length > 8 && trimmedCode.contains('*')
            ? 'Code lancé : ${trimmedCode.substring(0, trimmedCode.lastIndexOf('*') + 1)}...#'
            : 'Code lancé : $trimmedCode';

        await _historyService.logEvent(
          title: title ?? 'Exécution USSD',
          description: historyDescription,
          network: network,
          type: HistoryType.ussdLaunch,
        );
      } else {
        throw Exception('L\'application téléphone n\'a pas pu lancer l\'appel.');
      }

      return true;
    } catch (e, stack) {
      AuditService.logError('Erreur lors du lancement USSD', e, stack);
      if (!context.mounted) return false;

      _showFailure(context, 'Échec du lancement. Vérifiez les permissions.');
      return false;
    }
  }

  /// Construit un code USSD à partir d'un template et de données.
  static String buildFromTemplate({
    required String template,
    required Map<String, String> data,
  }) {
    String finalCode = template;
    
    data.forEach((key, value) {
      finalCode = finalCode.replaceAll('[$key]', value.trim());
    });

    // Nettoyage des espaces
    finalCode = finalCode.replaceAll(RegExp(r'\s+'), '');

    if (finalCode.contains('[')) {
      AuditService.logWarning('Certains paramètres du template USSD sont manquants : $finalCode');
      return '';
    }

    return finalCode;
  }

  static void _showFailure(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
