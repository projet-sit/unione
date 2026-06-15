import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'security_service.dart';
import 'history_service.dart';
import '../models/history_item.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UssdService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final HistoryService _historyService = HistoryService();

  static Future<bool> verifyIdentity() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true;

      return await _auth.authenticate(
        localizedReason: 'auth_reason'.tr(),
        authMessages: const [], // Optionnel, mais évite les erreurs de paramètres nommés
      );
    } catch (e) {
      AuditService.logError('Erreur d\'authentification locale', e);
      return false;
    }
  }

  static Future<bool> launchUssd(BuildContext context, String code, {String? title, String? network}) async {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      if (context.mounted) _showFailure(context, 'invalid_ussd'.tr());
      return false;
    }

    String encodedCode = trimmedCode;
    
    // On force le format USSD (*...#) uniquement si le code contient déjà * ou #, 
    // ou s'il s'agit d'un code court de exactement 3 chiffres (ex: 104 -> *104#).
    // Les numéros de 4 chiffres ou plus sans * ou # sont traités comme des numéros d'appel (ex: 7373).
    bool isUssd = encodedCode.contains('*') || encodedCode.contains('#') || encodedCode.length == 3;
    
    if (isUssd) {
      if (!encodedCode.endsWith('#')) encodedCode += '#';
      if (!encodedCode.startsWith('*')) encodedCode = '*$encodedCode';
    }

    try {
      await Permission.phone.request();
      if (!context.mounted) return false;

      bool? launched = await FlutterPhoneDirectCaller.callNumber(encodedCode);

      if (launched != true) {
        final Uri telUri = Uri(
          scheme: 'tel',
          path: encodedCode,
        );

        bool canLaunch = await canLaunchUrl(telUri);
        if (!context.mounted) return false;

        if (canLaunch) {
          await launchUrl(telUri);
          if (!context.mounted) return false;
          launched = true;
        }
      }

      if (launched == true) {
        await _historyService.logEvent(
          title: title ?? 'Opération USSD',
          description: 'history_ussd_executed',
          network: network,
          type: HistoryType.ussdLaunch,
        );
        return true;
      } else {
        throw Exception('Impossible de lancer l\'appel.');
      }
    } catch (e, stack) {
      AuditService.logError('Échec USSD', e, stack);
      if (!context.mounted) return false;
      _showFailure(context, 'launch_failed'.tr());
      return false;
    }
  }

  static String buildFromTemplate({
    required String template,
    required Map<String, String> data,
  }) {
    String finalCode = template;
    data.forEach((key, value) {
      finalCode = finalCode.replaceAll('{{$key}}', value.trim());
    });
    finalCode = finalCode.replaceAll(RegExp(r'\s+'), '');
    if (finalCode.contains('{{')) return '';
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
