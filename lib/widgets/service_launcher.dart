import 'dart:async';
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
      final launched = await UssdService.launchPhoneNumber(
        context,
        code,
        title: node.label,
        network: operator.name,
        serviceId: node.id,
      );
      if (launched) {
        await UserPreferencesService.instance.addRecent('n:${node.id}');
      }
    } else {
      final launched = await UssdService.launchUssd(
        context,
        code,
        title: node.label,
        network: operator.name,
        operatorId: operator.id,
        serviceId: node.id,
      );
      if (launched) {
        // L'écriture d'historique récente ne bloque pas l'UI.
        unawaited(
          UserPreferencesService.instance.addRecent('n:${node.id}'),
        );
      }
    }
  }

  static Future<void> launchOffer(
    BuildContext context, {
    required CatalogModel catalog,
    required OfferModel offer,
    required OperatorTree operator,
  }) async {
    final savedId = await UserPreferencesService.instance.catalogPayment(
      catalog.id,
    );
    final code = resolveOfferCode(
      catalog: catalog,
      offer: offer,
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
    final launched = await UssdService.launchUssd(
      context,
      code,
      title: title,
      network: operator.name,
      operatorId: operator.id,
      serviceId: offer.id,
    );
    if (launched) {
      // L'écriture d'historique récente ne bloque pas l'UI.
      unawaited(
        UserPreferencesService.instance.addRecent(
          'o:${catalog.id}:${offer.id}',
        ),
      );
    }
  }

  static Future<void> savePaymentOption({
    required String catalogId,
    required String optionId,
  }) => UserPreferencesService.instance.saveCatalogPayment(catalogId, optionId);

  /// Choisit la destination USSD la plus précise disponible pour une offre.
  ///
  /// Priorité :
  /// 1. `offer.launch` : code propre à l'offre.
  /// 2. option de paiement propre à l'offre (ex. `offer.payWith`).
  /// 3. option de catalogue réellement spécifique : elle contient `{price}`
  ///    ou pointe vers la même destination que `catalog.launch`.
  /// 4. `catalog.launch` : menu ou code direct du catalogue.
  ///
  /// Les options génériques d'un catalogue (ex. le menu Moov Money `*855*3*2#`)
  /// ne doivent jamais écraser la destination du catalogue : sinon toutes les
  /// offres atterrissent sur le même menu générique.
  @visibleForTesting
  static String resolveOfferCode({
    required CatalogModel catalog,
    required OfferModel offer,
    required String? selectedId,
  }) {
    final offerLaunch = offer.launch;
    if (offerLaunch != null && offerLaunch.code.isNotEmpty) {
      return _fillPrice(offerLaunch.code, offer.price);
    }

    final offerOptions = offer.payWith;
    if (offerOptions != null && offerOptions.isNotEmpty) {
      final selected = _selectedOption(offerOptions, selectedId);
      return _fillPrice(selected.code, offer.price);
    }

    final catalogOptions = catalog.payWith;
    if (catalogOptions.isNotEmpty) {
      final selected = _selectedOption(catalogOptions, selectedId);
      if (_isSpecificToCatalog(selected, catalog)) {
        return _fillPrice(selected.code, offer.price);
      }
    }

    return _fillPrice(catalog.launch.code, offer.price);
  }

  static CatalogPaymentOption _selectedOption(
    List<CatalogPaymentOption> options,
    String? selectedId,
  ) => options.firstWhere(
    (option) => option.id == selectedId,
    orElse: () => options.first,
  );

  static bool _isSpecificToCatalog(
    CatalogPaymentOption option,
    CatalogModel catalog,
  ) => option.code.contains('{price}') || option.code == catalog.launch.code;

  static String _fillPrice(String template, int price) =>
      template.replaceAll('{price}', price.toString());

  static SnackBar _snackBar(String message, {int seconds = 3}) => SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: Duration(seconds: seconds),
  );

  static void _showInfo(
    BuildContext context,
    String message, {
    int seconds = 3,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_snackBar(message, seconds: seconds));
  }
}
