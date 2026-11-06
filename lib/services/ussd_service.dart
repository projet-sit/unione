import 'package:flutter/material.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'security_service.dart';
import 'history_service.dart';
import '../models/history_item.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'android_ussd_gateway.dart';

class UssdService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final HistoryService _historyService = HistoryService();
  static final AndroidUssdGateway _gateway = AndroidUssdGateway();

  /// Vérifie qu'un code USSD bien formé : commence par `*`, finit par `#`,
  /// ne contient que des chiffres, `*` et `#`.
  /// Protège contre l'injection de codes provenant d'un JSON compromis.
  static final RegExp _ussdPattern = RegExp(r'^\*[\d*#]+#$');

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
    bool isUssd =
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

    try {
      // iOS ne donne pas accès à la réponse USSD : on ouvre directement le composeur.
      if (!Platform.isAndroid) {
        final launched = await _openDialer(encodedCode);
        if (launched) await _logLaunch(title, network, serviceId);
        if (!launched && context.mounted) _showFailure(context, 'launch_failed'.tr());
        return launched;
      }
      final permissionGranted = await _requestPhonePermission(context);
      if (!context.mounted) return false;
      if (permissionGranted) {
        final selection = await _chooseSim(context);
        if (!context.mounted) return false;
        if (selection.cancelled) return false;
        final sim = selection.sim;
        final result = await _gateway.execute(
          encodedCode,
          subscriptionId: sim?.subscriptionId,
        );
        if (result?.success == true) {
          await _logLaunch(title, network, serviceId);
          if (context.mounted &&
              result!.response != null &&
              result.response!.trim().isNotEmpty) {
            await _showResponse(context, result.response!);
          }
          return true;
        }
        if (result != null && result.error != null && context.mounted) {
          _showFailure(context, _readableError(result.error!));
        }
      }

      // iOS, Android antérieur à 8, permission refusée ou API opérateur indisponible.
      final launched = await _openDialer(encodedCode);
      if (launched) await _logLaunch(title, network, serviceId);
      if (!launched && context.mounted) {
        _showFailure(context, 'launch_failed'.tr());
      }
      return launched;
    } catch (e, stack) {
      AuditService.logError('Échec USSD', e, stack);
      if (!context.mounted) return false;
      _showFailure(context, 'launch_failed'.tr());
      return false;
    }
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
    final launched = await _openDialer(number.trim());
    if (launched) await _logLaunch(title, network, serviceId);
    if (!launched && context.mounted) _showFailure(context, 'launch_failed'.tr());
    return launched;
  }

  static Future<void> _logLaunch(String? title, String? network, String? serviceId) =>
      _historyService.logEvent(
        title: title ?? 'Opération USSD',
        description: 'history_ussd_executed',
        network: network,
        serviceId: serviceId,
        type: HistoryType.ussdLaunch,
      );

  static Future<bool> _requestPhonePermission(BuildContext context) async {
    if (await Permission.phone.isGranted) return true;
    if (!context.mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Autoriser les appels USSD ?'),
        content: const Text(
          'UNIONE utilise le téléphone et l’état de la SIM uniquement pour lancer le code USSD et vous laisser choisir une SIM. Aucune donnée de transaction ni code PIN n’est enregistrée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('PLUS TARD'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('AUTORISER'),
          ),
        ],
      ),
    );
    if (accepted != true) return false;
    return (await Permission.phone.request()).isGranted;
  }

  /// Demande systématiquement la carte SIM à utiliser (double SIM uniquement).
  /// Aucun choix n'est mémorisé : la question est posée à chaque opération.
  static Future<({SimCard? sim, bool cancelled})> _chooseSim(
    BuildContext context,
  ) async {
    final sims = await _gateway.getSims();
    if (sims.length < 2) {
      return (sim: sims.isEmpty ? null : sims.first, cancelled: false);
    }
    if (!context.mounted) return (sim: null, cancelled: true);
    final selected = await showModalBottomSheet<SimCard>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                'Choisir la carte SIM',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            ...sims.map(
              (sim) => ListTile(
                leading: Icon(
                  Icons.sim_card_rounded,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
                title: Text(sim.label),
                subtitle: sim.operatorName == null
                    ? null
                    : Text(sim.operatorName!),
                onTap: () => Navigator.pop(sheetContext, sim),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    return (sim: selected, cancelled: selected == null);
  }

  static Future<bool> _openDialer(String code) async {
    final uri = Uri.parse('tel:${code.replaceAll('#', '%23')}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> _showResponse(BuildContext context, String response) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Réponse USSD',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              SelectableText(response),
            ],
          ),
        ),
      );

  static String _readableError(String error) {
    final normalized = error.toLowerCase();
    if (normalized.contains('service') || normalized.contains('network')) {
      return 'Le réseau mobile est indisponible. Réessayez dans quelques instants.';
    }
    if (normalized.contains('sim') || normalized.contains('subscription')) {
      return 'Aucune carte SIM active n’a été trouvée.';
    }
    if (normalized.contains('cancel') || normalized.contains('reject')) {
      return 'Le code USSD a été refusé ou annulé par l’opérateur.';
    }
    return 'Le code USSD n’a pas pu être exécuté. Le composeur va être ouvert si disponible.';
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
    if (finalCode.contains('{{') || RegExp(r'\{[^}]+\}').hasMatch(finalCode)) return '';
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
