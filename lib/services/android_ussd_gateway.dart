import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Correspondance MCC-MNC (Bénin, MCC 616) → identifiant opérateur de l'app.
///
/// Codes PLMN attribués au Bénin : 616-02 Moov, 616-03 MTN, 616-07 Celtiis.
/// Les autres codes (Libercom, BBCOM, Glo) ne correspondent à aucun opérateur
/// proposé par UNIONE et renvoient `null`.
String? operatorIdFromMccMnc(String? mccMnc) {
  switch (mccMnc?.trim()) {
    case '61602':
      return 'moov';
    case '61603':
      return 'mtn';
    case '61607':
      return 'celtiis';
    default:
      return null;
  }
}

/// Pont Android vers le composeur système.
///
/// Le lancement principal utilise `ACTION_CALL` avec une URI `tel:` encodée :
/// Android se comporte exactement comme si l'utilisateur avait composé le code
/// au clavier (fenêtre de choix de SIM système, puis dialogue USSD opérateur).
class AndroidUssdGateway {
  static const _channel = MethodChannel('com.zoli.app/unione_ussd');

  /// Déclenche directement l'appel du code USSD (`ACTION_CALL`).
  ///
  /// Lève une [PlatformException] si Android refuse ou ne peut pas démarrer
  /// l'appel : l'appelant journalise l'erreur et bascule sur le composeur.
  Future<bool> launchNative(String code) async {
    if (!Platform.isAndroid) return false;
    final launched = await _channel.invokeMethod<bool>('launchUssd', {
      'code': code,
    });
    return launched == true;
  }

  /// Ouvre le composeur pré-rempli (`ACTION_DIAL`) sans lancer l'appel.
  Future<bool> dialNative(String code) async {
    if (!Platform.isAndroid) return false;
    final dialed = await _channel.invokeMethod<bool>('dialUssd', {
      'code': code,
    });
    return dialed == true;
  }

  /// Code MCC-MNC de la SIM par défaut, ou `null` si indisponible.
  ///
  /// `TelephonyManager.getSimOperator()` ne requiert aucune permission.
  /// Détection « au mieux » : jamais d'erreur remontée à l'utilisateur.
  Future<String?> simOperator() async {
    if (!Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<String>('getSimOperator');
    } on PlatformException catch (error) {
      debugPrint('[UNIONE] getSimOperator indisponible: ${error.code}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
