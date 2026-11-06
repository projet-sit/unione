import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

/// Résultat d'une tentative d'ouverture de WhatsApp.
enum WhatsAppLaunchStatus {
  /// L'application WhatsApp a été ouverte directement.
  app,

  /// WhatsApp n'est pas installé : le lien a été ouvert dans un navigateur.
  browser,

  /// Aucune application n'a pu être ouverte.
  failed,
}

/// Ouverture centralisée de WhatsApp, avec repli navigateur.
///
/// Le schéma `whatsapp://` ouvre directement l'application quand elle est
/// installée. Sinon, le lien `https://wa.me/...` est ouvert dans le navigateur
/// par défaut, sans jamais bloquer l'utilisateur.
class WhatsAppLauncher {
  const WhatsAppLauncher._();

  static Future<WhatsAppLaunchStatus> open({String? message}) async {
    try {
      final appUri = AppConfig.whatsappAppUri(message: message);
      if (await canLaunchUrl(appUri)) {
        final opened = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return WhatsAppLaunchStatus.app;
      }
    } catch (_) {
      // WhatsApp absent ou schéma non géré : on passe au repli navigateur.
    }

    try {
      final webUri = AppConfig.whatsappUri(message: message);
      final opened = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return WhatsAppLaunchStatus.browser;
    } catch (_) {
      // Aucune application disponible.
    }

    return WhatsAppLaunchStatus.failed;
  }

  /// Ouvre WhatsApp et affiche un message clair en cas de repli ou d'échec.
  static Future<WhatsAppLaunchStatus> openWithFeedback(
    BuildContext context, {
    String? message,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await open(message: message);
    notify(messenger, status);
    return status;
  }

  /// Affiche le retour utilisateur associé à [status].
  static void notify(
    ScaffoldMessengerState messenger,
    WhatsAppLaunchStatus status,
  ) {
    final text = switch (status) {
      WhatsAppLaunchStatus.app => null,
      WhatsAppLaunchStatus.browser => 'whatsapp_browser_fallback'.tr(),
      WhatsAppLaunchStatus.failed => 'whatsapp_open_failed'.tr(),
    };
    if (text == null) return;
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}
