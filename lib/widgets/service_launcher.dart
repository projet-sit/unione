import 'package:flutter/material.dart';

import '../models/catalog_model.dart';
import '../models/menu_node.dart';
import '../screens/action_screen.dart';
import '../services/user_preferences_service.dart';
import '../services/ussd_service.dart';

/// Point unique de lancement des opérations.
/// Un tap lance directement le code USSD : plus d'écran de détail,
/// plus de feuille de confirmation, plus de code affiché à l'écran.
/// L'écran de saisie n'est gardé que pour les opérations ussd_param.
class ServiceLauncher {
  const ServiceLauncher._();

  static Future<void> launchNode(
    BuildContext context, {
    required MenuNode node,
    required OperatorTree operator,
  }) async {
    if (node.code == null || node.status != 'ok') {
      _showInfo(
        context,
        node.status == 'obsolete'
            ? 'Ce code est obsolète. Il va être corrigé.'
            : 'Code bientôt disponible. Vérification en cours.',
      );
      return;
    }
    if (node.params.isNotEmpty) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ActionScreen(nodeId: node.id)),
      );
      return;
    }
    final code = node.code!;
    if (node.launchKind == 'call') {
      await UssdService.launchPhoneNumber(
        context,
        code,
        title: node.label,
        network: operator.name,
        serviceId: node.id,
      );
    } else {
      await UssdService.launchUssd(
        context,
        code,
        title: node.label,
        network: operator.name,
        operatorId: operator.id,
        serviceId: node.id,
      );
    }
  }

  static Future<void> launchOffer(
    BuildContext context, {
    required CatalogModel catalog,
    required OfferModel offer,
    required OperatorTree operator,
  }) async {
    final options = offer.payWith ?? catalog.payWith;
    final savedId = await UserPreferencesService.instance
        .catalogPayment(catalog.id);
    final code = _resolveOfferCode(
      catalog: catalog,
      offer: offer,
      options: options,
      selectedId: savedId,
    );
    if (code.isEmpty) {
      if (context.mounted) {
        _showInfo(context, 'Activation indisponible pour ce forfait.');
      }
      return;
    }
    if (context.mounted && offer.hint?.isNotEmpty == true) {
      _showInfo(
        context,
        'Dans le menu qui s\u2019affiche : ${offer.hint}',
        seconds: 4,
      );
    }
    if (!context.mounted) return;
    final title = '${catalog.label} : ${offer.title} (${offer.price} F)';
    await UssdService.launchUssd(
      context,
      code,
      title: title,
      network: operator.name,
      operatorId: operator.id,
      serviceId: offer.id,
    );
  }

  static Future<void> savePaymentOption({
    required String catalogId,
    required String optionId,
  }) =>
      UserPreferencesService.instance.saveCatalogPayment(catalogId, optionId);

  static String _resolveOfferCode({
    required CatalogModel catalog,
    required OfferModel offer,
    required List<CatalogPaymentOption> options,
    required String? selectedId,
  }) {
    String template;
    if (options.isNotEmpty) {
      final selected = options.firstWhere(
        (option) => option.id == selectedId,
        orElse: () => options.first,
      );
      template = selected.code;
    } else if (offer.launch != null) {
      template = offer.launch!.code;
    } else {
      template = catalog.launch.code;
    }
    return template.replaceAll('{price}', offer.price.toString());
  }

  static SnackBar _snackBar(String message, {int seconds = 3}) => SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: seconds),
      );

  static void _showInfo(BuildContext context, String message, {int seconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(_snackBar(message, seconds: seconds));
  }
}
