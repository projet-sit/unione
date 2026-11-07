import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/history_item.dart';
import 'android_ussd_gateway.dart';
import 'history_service.dart';
import 'security_service.dart';
import 'user_preferences_service.dart';

class UssdService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final HistoryService _historyService = HistoryService();
  static final AndroidUssdGateway _gateway = AndroidUssdGateway();

  /// Vérifie qu'un code USSD bien formé : commence par `*`, finit par `#`,
  /// ne contient que des chiffres, `*` et `#`.
  /// Protège contre l'injection de codes provenant d'un JSON compromis.
  static final RegExp _ussdPattern = RegExp(r'^\*[\d*#]+#$');

  /// Construit l'URI `tel:` d'un code USSD.
  ///
  /// `#` est encodé en `%23` (sinon Android le traite comme un fragment et
  /// tronque le code). Les `*` restent littéraux : `*880#` → `tel:*880%23`.
  static String buildTelUri(String code) =>
      'tel:${code.replaceAll('#', '%23')}';

  static Future<bool> verifyIdentity() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true;

      return await _auth.authenticate(
        localizedReason: 'auth_reason'.tr(),
        authMessages:
            const [], // Optionnel, mais évite les erreurs de paramètres nommés
      );
    } catch (e) {
      AuditService.logError('Erreur d\'authentification locale', e);
      return false;
    }
  }

  /// Lance un code USSD via `ACTION_CALL` (comportement d'une composition
  /// manuelle au clavier).
  ///
  /// Aucune SIM n'est transmise à l'intent : Android affiche lui-même sa
  /// fenêtre de choix de SIM (ou utilise la SIM par défaut des appels), puis
  /// ouvre le dialogue USSD de l'opérateur. L'application ne présente aucun
  /// sélecteur de SIM.
  static Future<bool> launchUssd(
    BuildContext context,
    String code, {
    String? title,
    String? network,
    String? operatorId,
    String? serviceId,
  }) async {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      if (context.mounted) _showFailure(context, 'invalid_ussd'.tr());
      return false;
    }

    String encodedCode = trimmedCode;

    // On force le format USSD (*...#) uniquement si le code contient déjà * ou #,
    // ou s'il s'agit d'un code court de exactement 3 chiffres (ex: 104 -> *104#).
    // Les numéros de 4 chiffres ou plus sans * ou # sont traités comme des numéros d'appel (ex: 7373).
    final bool isUssd =
        encodedCode.contains('*') ||
        encodedCode.contains('#') ||
        encodedCode.length == 3;

    if (isUssd) {
      if (!encodedCode.endsWith('#')) encodedCode += '#';
      if (!encodedCode.startsWith('*')) encodedCode = '*$encodedCode';

      // Validation de sécurité : rejette les codes USSD malformés.
      if (!_ussdPattern.hasMatch(encodedCode)) {
        AuditService.logError('Code USSD invalide rejeté', encodedCode);
        if (context.mounted) _showFailure(context, 'invalid_ussd'.tr());
        return false;
      }
    }

    final telUri = buildTelUri(encodedCode);
    if (kDebugMode) {
      debugPrint('[UNIONE] URI USSD finale: $telUri');
    }

    // iOS ne donne pas accès à la réponse USSD : on ouvre directement le composeur.
    if (!Platform.isAndroid) {
      return _openDialer(
        context,
        encodedCode,
        title: title,
        network: network,
        serviceId: serviceId,
      );
    }

    final permissionGranted = await _requestPhonePermission(context);
    if (!context.mounted) return false;

    if (!permissionGranted) {
      AuditService.logWarning(
        'Permission CALL_PHONE refusée : ouverture du composeur.',
      );
      _showFailure(context, 'phone_permission_denied'.tr());
      return _openDialer(
        context,
        encodedCode,
        title: title,
        network: network,
        serviceId: serviceId,
      );
    }

    try {
      final launched = await _gateway.launchNative(encodedCode);
      if (launched) {
        await _logLaunch(title, network, serviceId);
        return true;
      }
      AuditService.logError('ACTION_CALL non démarré', telUri);
      if (context.mounted) _showFailure(context, 'launch_direct_failed'.tr());
    } on PlatformException catch (e, stack) {
      AuditService.logError('Échec ACTION_CALL', e, stack);
      if (context.mounted) _showFailure(context, 'launch_direct_failed'.tr());
    } on MissingPluginException catch (e, stack) {
      AuditService.logError('MethodChannel USSD indisponible', e, stack);
      if (context.mounted) _showFailure(context, 'launch_direct_failed'.tr());
    }

    // Repli : composeur pré-rempli, sans lancer l'appel.
    if (!context.mounted) return false;
    return _openDialer(
      context,
      encodedCode,
      title: title,
      network: network,
      serviceId: serviceId,
    );
  }

  /// Lance un numéro classique dans le composeur et conserve le même historique
  /// minimal que pour les feuilles USSD. Les numéros courts (ex. 7373) ne
  /// doivent jamais être envoyés à l’API USSD Android.
  static Future<bool> launchPhoneNumber(
    BuildContext context,
    String number, {
    String? title,
    String? network,
    String? serviceId,
  }) async {
    return _openDialer(
      context,
      number.trim(),
      title: title,
      network: network,
      serviceId: serviceId,
    );
  }

  static Future<void> _logLaunch(
    String? title,
    String? network,
    String? serviceId,
  ) => _historyService.logEvent(
    title: title ?? 'Opération USSD',
    description: 'history_ussd_executed',
    network: network,
    serviceId: serviceId,
    type: HistoryType.ussdLaunch,
  );

  /// Demande la permission d'appel via le dialogue système Android.
  ///
  /// Une explication est affichée une seule fois avant le dialogue système :
  /// les utilisateurs acceptent mieux une autorisation qu'ils comprennent.
  static Future<bool> _requestPhonePermission(BuildContext context) async {
    if (await Permission.phone.isGranted) return true;
    if (await Permission.phone.isPermanentlyDenied) return false;

    final primingSeen = await UserPreferencesService.instance
        .phonePrimingSeen();
    if (!primingSeen) {
      if (!context.mounted) return false;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Autoriser les appels USSD',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'UNIONE utilise l’autorisation Téléphone uniquement pour lancer '
            'le code USSD que vous choisissez. Android gère la carte SIM et '
            'aucun appel n’est enregistré.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Plus tard'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      await UserPreferencesService.instance.setPhonePrimingSeen();
      if (accepted != true || !context.mounted) return false;
    }

    if (!context.mounted) return false;
    return (await Permission.phone.request()).isGranted;
  }

  /// Ouvre le composeur pré-rempli (`ACTION_DIAL` sur Android).
  /// Ne lance jamais l'appel : l'utilisateur appuie lui-même sur « Appeler ».
  static Future<bool> _openDialer(
    BuildContext context,
    String code, {
    String? title,
    String? network,
    String? serviceId,
  }) async {
    final uri = buildTelUri(code);
    try {
      final bool launched;
      if (Platform.isAndroid) {
        launched = await _gateway.dialNative(code);
      } else {
        launched = await launchUrl(
          Uri.parse(uri),
          mode: LaunchMode.externalApplication,
        );
      }
      if (launched) {
        await _logLaunch(title, network, serviceId);
        return true;
      }
      AuditService.logError('Composeur indisponible', uri);
    } on PlatformException catch (e, stack) {
      AuditService.logError('Échec ACTION_DIAL', e, stack);
    } on MissingPluginException catch (e, stack) {
      AuditService.logError('MethodChannel composeur indisponible', e, stack);
    } catch (e, stack) {
      AuditService.logError('Échec du composeur', e, stack);
    }
    if (context.mounted) _showFailure(context, 'launch_failed'.tr());
    return false;
  }

  static String buildFromTemplate({
    required String template,
    required Map<String, String> data,
  }) {
    if (RegExp(r'\{[^}]*pin[^}]*\}', caseSensitive: false).hasMatch(template) ||
        data.keys.any((key) => key.toLowerCase().contains('pin'))) {
      return '';
    }
    String finalCode = template;
    data.forEach((key, value) {
      finalCode = finalCode.replaceAll('{{$key}}', value.trim());
      finalCode = finalCode.replaceAll('{$key}', value.trim());
    });
    finalCode = finalCode.replaceAll(RegExp(r'\s+'), '');
    if (finalCode.contains('{{') || RegExp(r'\{[^}]+\}').hasMatch(finalCode)) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
