import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

import '../models/catalog_model.dart';
import '../models/history_item.dart';
import '../models/menu_node.dart';
import '../models/reseau.dart';
import '../services/android_ussd_gateway.dart';
import '../services/codes_repository.dart';
import '../services/history_service.dart';
import '../services/theme_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/operation_menu_sheet.dart';
import '../widgets/operator_logo.dart';
import '../widgets/reseau_card.dart';
import '../widgets/service_launcher.dart';
import '../widgets/skeleton_loader.dart';
import 'catalog_screen.dart';
import 'menu_screen.dart';
import 'settings_screen.dart';

class SelectionReseauScreen extends StatefulWidget {
  const SelectionReseauScreen({super.key});
  @override
  State<SelectionReseauScreen> createState() => _SelectionReseauScreenState();
}

class _SelectionReseauScreenState extends State<SelectionReseauScreen> {
  final _history = HistoryService();
  final _search = TextEditingController();
  Timer? _debounce;
  Set<String> _favorites = {};
  String? _detectedOperator;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _loadPersonalization();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final path in OperatorLogo.availableAssets) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalization() async {
    final favorites = await UserPreferencesService.instance.favorites();
    String? detected;
    if (!kIsWeb && Platform.isAndroid) {
      final mccMnc = await AndroidUssdGateway().simOperator();
      detected = operatorIdFromMccMnc(mccMnc);
    }
    if (mounted) setState(() { _favorites = favorites; _detectedOperator = detected; });
  }

  Future<void> _openOperator(OperatorTree operator) async {
    await _history.logEvent(title: 'history_network_title', description: 'history_network_selected|${operator.name}', network: operator.name, type: HistoryType.networkSelection);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(nodeId: 'operator:${operator.id}')));
    _loadPersonalization();
  }

  Future<void> _openNode(MenuNode node, OperatorTree operator) async {
    if (node.type == MenuNodeType.catalog) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CatalogScreen(
            catalogId: node.catalogId ?? node.id,
            title: node.label,
          ),
        ),
      );
      _loadPersonalization();
    } else {
      await ServiceLauncher.launchNode(context, node: node, operator: operator);
    }
  }

  Future<void> _openOffer(CatalogModel catalog, OfferModel offer, OperatorTree operator) async {
    await ServiceLauncher.launchOffer(context, catalog: catalog, offer: offer, operator: operator);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: themeNotifier,
    builder: (context, _) => ValueListenableBuilder<UssdTree?>(
      valueListenable: CodesRepository.instance.catalogue,
      builder: (context, tree, _) {
        if (tree == null) {
          return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 36), children: [
            _header(), const SizedBox(height: 28),
            const SkeletonBox(height: 52, borderRadius: 18),
            const SizedBox(height: 28),
            const SkeletonBox(height: 20, width: 180, borderRadius: 6),
            const SizedBox(height: 20),
            const SkeletonReseauCard(),
            const SkeletonReseauCard(),
            const SkeletonReseauCard(),
          ])));
        }
        final query = _search.text.trim().toLowerCase();
        final operators = [...tree.operators]..sort((a, b) => a.id == _detectedOperator ? -1 : b.id == _detectedOperator ? 1 : 0);
        final searchableNodes = tree.searchableNodes.toList(growable: false);
        final results = query.isEmpty ? const <MenuNode>[] : searchableNodes.where((node) => [node.label, node.category ?? '', ...node.keywords].join(' ').toLowerCase().contains(query)).toList();
        final favorites = searchableNodes.where((node) => _favorites.contains(node.id)).toList();

        return ValueListenableBuilder<CatalogsData?>(
          valueListenable: CodesRepository.instance.catalogs,
          builder: (context, catalogsData, _) {
            final matchingOffers = <_OfferSearchResult>[];
            if (query.isNotEmpty && catalogsData != null) {
              for (final cat in catalogsData.catalogs.values) {
                final op = tree.operators.firstWhere(
                  (o) => o.id.toLowerCase() == cat.operator.toLowerCase(),
                  orElse: () => tree.operators.first,
                );
                for (final off in cat.offers) {
                  final searchBlob = [
                    off.title,
                    '${off.price}',
                    '${off.price} fcfa',
                    off.validityLabel ?? '',
                    ...off.badges,
                    ...off.contents,
                    cat.label,
                    op.name,
                  ].join(' ').toLowerCase();

                  if (searchBlob.contains(query)) {
                    matchingOffers.add(_OfferSearchResult(
                      catalog: cat,
                      offer: off,
                      operator: op,
                    ));
                  }
                }
              }
            }

            final hasResults = results.isNotEmpty || matchingOffers.isNotEmpty;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 36), children: [
                _header(), const SizedBox(height: 28),
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Rechercher : solde, forfait, 1 Go, 500, illimité…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: _search.clear),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 28),
                if (query.isNotEmpty) ...[
                  _title('Résultats'),
                  if (!hasResults)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text('Aucun service ni forfait ne correspond à votre recherche.'),
                    ),
                  if (matchingOffers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'FORFAITS (${matchingOffers.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _offerResultsList(matchingOffers),
                  ],
                  if (results.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'SERVICES & CATALOGUES (${results.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _actionList(tree, results),
                  ],
                ] else ...[
                  if (favorites.isNotEmpty) ...[_title('Favoris'), _actionList(tree, favorites)],
                  _title('Veuillez sélectionner un réseau :'),
                  ...operators.map((operator) => Padding(padding: const EdgeInsets.only(bottom: 16), child: ReseauCard(reseau: _toReseau(operator), onTap: () => _openOperator(operator)))),
                ],
              ])),
            );
          },
        );
      },
    ),
  );

  Widget _header() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: const AppLogo(size: 32)), const SizedBox(width: 14), Text('UNIONE', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w900))]),
    IconButton(icon: const Icon(Icons.settings_outlined), tooltip: 'Paramètres', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
  ]);

  Widget _title(String title) => Padding(padding: const EdgeInsets.only(bottom: 14, top: 4), child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 25, fontWeight: FontWeight.w900)));

  Widget _actionList(UssdTree tree, List<MenuNode> nodes, {String? empty}) => nodes.isEmpty
      ? Padding(padding: const EdgeInsets.only(bottom: 24), child: Text(empty ?? ''))
      : Padding(padding: const EdgeInsets.only(bottom: 26), child: Column(children: nodes.map((node) {
          final operator = tree.operatorFor(node.id)!;
          final path = tree.breadcrumb(node.id).map((item) => item.label).toList()..removeLast();
          final subtitle = [operator.name, ...path].join(' › ');
          final isCatalog = node.type == MenuNodeType.catalog;

          return Semantics(
            label: '${node.label}, $subtitle. Appuyez pour accéder.',
            button: true,
            excludeSemantics: true,
            child: Card(child: ListTile(
              onTap: () => _openNode(node, operator),
              onLongPress: () async {
                final result = await OperationMenuSheet.show(context, node: node, operator: operator, tree: tree, favorite: _favorites.contains(node.id));
                if (result == null) return;
                setState(() {
                  result ? _favorites.add(node.id) : _favorites.remove(node.id);
                });
              },
              leading: OperatorLogo(operatorId: operator.id, size: 40, borderRadius: 10),
              title: Text(node.label, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(subtitle),
              trailing: isCatalog
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: OperatorLogo.accent(context, operator.color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CATALOGUE',
                        style: TextStyle(
                          color: OperatorLogo.accent(context, operator.color),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : const Icon(Icons.chevron_right_rounded),
            )),
          );
        }).toList()));

  Widget _offerResultsList(List<_OfferSearchResult> matches) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        children: matches.map((match) {
          final title = match.offer.title == 'à confirmer' ? 'Forfait à confirmer' : match.offer.title;
          final subtitle = '${match.catalog.label} · ${match.operator.name}${match.offer.validityLabel != null ? ' · ${match.offer.validityLabel}' : ''}';

          return Semantics(
            label: '$title, ${match.offer.price} FCFA, $subtitle. Appuyez pour lancer l’activation.',
            button: true,
            excludeSemantics: true,
            child: Card(
              child: ListTile(
                onTap: () => _openOffer(match.catalog, match.offer, match.operator),
                leading: OperatorLogo(operatorId: match.operator.id, size: 40, borderRadius: 10),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(subtitle),
                trailing: Text(
                  '${match.offer.price} F',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: OperatorLogo.accent(context, match.operator.color),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Reseau _toReseau(OperatorTree operator) => Reseau(type: switch (operator.id) { 'mtn' => ReseauType.mtn, 'moov' => ReseauType.moov, _ => ReseauType.celtiis }, nom: operator.name, couleur: operator.color, logoLabel: operator.name.toUpperCase());
}

class _OfferSearchResult {
  final CatalogModel catalog;
  final OfferModel offer;
  final OperatorTree operator;
  const _OfferSearchResult({
    required this.catalog,
    required this.offer,
    required this.operator,
  });
}
