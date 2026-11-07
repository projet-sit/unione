import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/catalog_model.dart';
import '../models/menu_node.dart';
import '../services/codes_repository.dart';
import '../services/user_preferences_service.dart';
import '../services/whatsapp_launcher.dart';
import '../widgets/offer_recipient_sheet.dart';
import '../widgets/operator_logo.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/service_launcher.dart';
import '../widgets/skeleton_loader.dart';
import 'selection_reseau_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String catalogId;
  final String? title;

  const CatalogScreen({super.key, required this.catalogId, this.title});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedTabIndex = 0;

  int? _maxBudget;
  String _sortMode = 'price';
  final Set<String> _compareIds = {};

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _setupTabController(List<CatalogTab> activeTabs) {
    if (activeTabs.isEmpty) return;
    if (_tabController == null || _tabController!.length != activeTabs.length) {
      _tabController?.dispose();
      final initialIndex = _selectedTabIndex.clamp(0, activeTabs.length - 1);
      _tabController = TabController(
        length: activeTabs.length,
        vsync: this,
        initialIndex: initialIndex,
      );
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          _selectedTabIndex = _tabController!.index;
        }
      });
    }
  }

  bool _isOutdated(String? verifiedAt) {
    if (verifiedAt == null) return false;
    final date = DateTime.tryParse(verifiedAt);
    if (date == null) return false;
    return DateTime.now().difference(date).inDays > 60;
  }

  Future<void> _reportIncorrectTariff({
    required BuildContext context,
    required String operatorName,
    required String catalogLabel,
    required String? verifiedAt,
  }) async {
    await WhatsAppLauncher.openWithFeedback(
      context,
      message: AppConfig.reportCatalogMessage(
        operatorName: operatorName,
        catalogLabel: catalogLabel,
        verifiedAt: verifiedAt,
      ),
    );
  }

  void _toggleCompare(OfferModel offer) {
    if (_compareIds.contains(offer.id)) {
      setState(() => _compareIds.remove(offer.id));
      return;
    }
    if (_compareIds.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au maximum 2 offres à comparer.'),
        ),
      );
      return;
    }
    setState(() => _compareIds.add(offer.id));
  }

  void _showComparison(CatalogModel catalog, OperatorTree operator) {
    final offers = catalog.offers
        .where((offer) => _compareIds.contains(offer.id))
        .toList();
    if (offers.length != 2) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comparer les offres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(sheetContext).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CompareColumn(
                      offer: offers[0],
                      operator: operator,
                      onLaunch: () => ServiceLauncher.launchOffer(
                        sheetContext,
                        catalog: catalog,
                        offer: offers[0],
                        operator: operator,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompareColumn(
                      offer: offers[1],
                      operator: operator,
                      onLaunch: () => ServiceLauncher.launchOffer(
                        sheetContext,
                        catalog: catalog,
                        offer: offers[1],
                        operator: operator,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerControls(List<OfferModel> offers) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Budget :',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(width: 8),
                ...[1000, 2000, 5000].map((amount) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      label: Text('≤ $amount F'),
                      selected: _maxBudget == amount,
                      onSelected: (selected) {
                        setState(() => _maxBudget = selected ? amount : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              PopupMenuButton<String>(
                initialValue: _sortMode,
                tooltip: 'Trier les offres',
                onSelected: (value) => setState(() => _sortMode = value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'price', child: Text('Prix croissant')),
                  PopupMenuItem(
                    value: 'volume',
                    child: Text('Volume décroissant'),
                  ),
                ],
                child: Chip(
                  avatar: Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    _sortMode == 'volume' ? 'Volume' : 'Prix',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${offers.length} offre${offers.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CatalogsData?>(
      valueListenable: CodesRepository.instance.catalogs,
      builder: (context, catalogsData, _) {
        final catalog = catalogsData?.catalog(widget.catalogId);

        return ValueListenableBuilder<UssdTree?>(
          valueListenable: CodesRepository.instance.catalogue,
          builder: (context, tree, _) {
            if (catalogsData == null || tree == null) {
              return _buildLoadingScaffold(context);
            }

            if (catalog == null) {
              return _buildEmptyScaffold(
                context,
                'Ce catalogue de forfaits est indisponible.',
              );
            }

            final operator = tree.operators.firstWhere(
              (op) => op.id.toLowerCase() == catalog.operator.toLowerCase(),
              orElse: () => OperatorTree(
                id: catalog.operator,
                name: catalog.operator.toUpperCase(),
                country: 'Bénin',
                color: const Color(0xFF2563EB),
                rootCode: '*199#',
                children: const [],
              ),
            );

            // Filtrer les onglets qui contiennent au moins une offre
            final activeTabs = catalog.tabs.where((tab) {
              return catalog.offers.any((offer) => offer.tab == tab.id);
            }).toList();

            _setupTabController(activeTabs);

            final operatorColor = operator.color;
            final isMtn = operator.id.toLowerCase() == 'mtn';
            final headerFgColor = isMtn
                ? const Color(0xFF1A1A1A)
                : Colors.white;
            final accentIndicatorColor = isMtn
                ? const Color(0xFF1A1A1A)
                : Colors.white;

            final isOutdated = _isOutdated(catalog.verifiedAt);
            final bestOfferId = catalog.bestValueOfferId;

            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              appBar: AppBar(
                backgroundColor: operatorColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: headerFgColor),
                  tooltip: 'Retour',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OperatorLogo(
                      operatorId: operator.id,
                      size: 26,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.title ?? catalog.label,
                        style: TextStyle(
                          color: headerFgColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close, color: headerFgColor),
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SelectionReseauScreen(),
                      ),
                      (route) => false,
                    ),
                  ),
                ],
                bottom: activeTabs.length > 1
                    ? TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: accentIndicatorColor,
                        indicatorWeight: 3,
                        labelColor: headerFgColor,
                        unselectedLabelColor: headerFgColor.withValues(
                          alpha: 0.65,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        tabs: activeTabs
                            .map((t) => Tab(text: t.label.toUpperCase()))
                            .toList(),
                      )
                    : null,
              ),
              body: SafePage(
                child: activeTabs.isEmpty
                    ? _buildEmptyOffers(context)
                    : TabBarView(
                        controller: _tabController,
                        children: activeTabs.map((tab) {
                          final tabOffers = catalog.offers
                              .where((o) => o.tab == tab.id)
                              .toList();
                          final visibleOffers = tabOffers
                              .where(
                                (offer) =>
                                    _maxBudget == null ||
                                    offer.price <= _maxBudget!,
                              )
                              .toList();
                          if (_sortMode == 'volume') {
                            visibleOffers.sort((a, b) {
                              final volumeA = a.dataVolumeMb ?? 0;
                              final volumeB = b.dataVolumeMb ?? 0;
                              return volumeB.compareTo(volumeA);
                            });
                          } else {
                            visibleOffers.sort(
                              (a, b) => a.price.compareTo(b.price),
                            );
                          }

                          final List<Widget> items = [];
                          items.add(_offerControls(visibleOffers));
                          if (catalog.payWith.length > 1) {
                            items.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _PaymentSelector(catalog: catalog),
                              ),
                            );
                          }
                          if (isOutdated) {
                            items.add(
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.shade700.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.amber.shade800,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Ces tarifs peuvent avoir changé récemment.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (visibleOffers.isEmpty) {
                            items.add(
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'Aucune offre dans ce budget.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          items.addAll(
                            visibleOffers.map(
                              (offer) => _OfferCard(
                                offer: offer,
                                catalog: catalog,
                                operator: operator,
                                isBestValue: offer.id == bestOfferId,
                                compareSelected: _compareIds.contains(offer.id),
                                onCompare: () => _toggleCompare(offer),
                                onTap: () async {
                                  final hasOther = offer.other != null &&
                                      offer.other!.code != null &&
                                      offer.other!.code!.isNotEmpty &&
                                      (offer.status == null ||
                                          offer.status == 'ok');
                                  if (!hasOther) {
                                    await ServiceLauncher.launchOffer(
                                      context,
                                      catalog: catalog,
                                      offer: offer,
                                      operator: operator,
                                    );
                                    return;
                                  }
                                  final recipient =
                                      await OfferRecipientSheet.show(
                                    context,
                                    offer: offer,
                                    operator: operator,
                                  );
                                  if (recipient == null) return;
                                  if (!context.mounted) return;
                                  await ServiceLauncher.launchOffer(
                                    context,
                                    catalog: catalog,
                                    offer: offer,
                                    operator: operator,
                                    recipient: recipient,
                                  );
                                },
                              ),
                            ),
                          );
                          items.add(const SizedBox(height: 20));
                          items.add(
                            Center(
                              child: Column(
                                children: [
                                  if (catalog.verifiedAt != null)
                                    Text(
                                      'Tarifs mis à jour le ${catalog.verifiedAt}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: operatorColor,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () => _reportIncorrectTariff(
                                      context: context,
                                      operatorName: operator.name,
                                      catalogLabel: catalog.label,
                                      verifiedAt: catalog.verifiedAt,
                                    ),
                                    icon: const Icon(
                                      Icons.report_problem_outlined,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Signaler un tarif incorrect',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          return ListView.builder(
                            key: PageStorageKey<String>(
                              'catalog_${widget.catalogId}_${tab.id}',
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            itemCount: items.length,
                            itemBuilder: (context, index) => items[index],
                          );
                        }).toList(),
                      ),
              ),
              bottomNavigationBar: _compareIds.length == 2
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: operatorColor,
                            foregroundColor: headerFgColor,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () => _showComparison(catalog, operator),
                          icon: const Icon(Icons.compare_arrows_rounded),
                          label: const Text(
                            'Comparer les 2 offres',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Chargement...')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SkeletonBox(height: 48, borderRadius: 12),
          SizedBox(height: 16),
          SkeletonBox(height: 90, borderRadius: 18),
          SizedBox(height: 12),
          SkeletonBox(height: 90, borderRadius: 18),
          SizedBox(height: 12),
          SkeletonBox(height: 90, borderRadius: 18),
        ],
      ),
    );
  }

  Widget _buildEmptyScaffold(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Catalogue')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('RETOUR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOffers(BuildContext context) {
    return const Center(
      child: Text('Aucune offre disponible dans ce catalogue pour le moment.'),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  final CatalogModel catalog;
  final OperatorTree operator;
  final bool isBestValue;
  final bool compareSelected;
  final VoidCallback onCompare;
  final VoidCallback onTap;

  const _OfferCard({
    required this.offer,
    required this.catalog,
    required this.operator,
    required this.isBestValue,
    required this.compareSelected,
    required this.onCompare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOfficial = offer.confidence == 'official';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: compareSelected
            ? Border.all(color: OperatorLogo.accent(context, operator.color))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Colonne de gauche : Titre / Contenu / Validité / Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      if (offer.validityLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          offer.validityLabel!,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      // Badges
                      if (isBestValue ||
                          offer.badges.isNotEmpty ||
                          isOfficial) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isBestValue)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.thumb_up_alt_rounded,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Meilleur rapport',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ...offer.badges.map(
                              (badge) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: operator.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: OperatorLogo.accent(
                                      context,
                                      operator.color,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            if (isOfficial)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 11,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Colonne de droite : Prix et bouton de comparaison
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${offer.price} F',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: OperatorLogo.accent(context, operator.color),
                      ),
                    ),
                    Text(
                      'FCFA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: compareSelected
                          ? 'Retirer de la comparaison'
                          : 'Comparer cette offre',
                      onPressed: onCompare,
                      icon: Icon(
                        compareSelected
                            ? Icons.check_circle_rounded
                            : Icons.compare_arrows_rounded,
                        size: 20,
                        color: compareSelected
                            ? OperatorLogo.accent(context, operator.color)
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.35,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur persistant du mode de paiement (ex. Crédit principal / Moov Money).
/// Le choix est mémorisé par catalogue et appliqué au lancement direct des offres.
class _PaymentSelector extends StatefulWidget {
  final CatalogModel catalog;
  const _PaymentSelector({required this.catalog});

  @override
  State<_PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<_PaymentSelector> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await UserPreferencesService.instance.catalogPayment(
      widget.catalog.id,
    );
    final options = widget.catalog.payWith;
    final valid = options.where((option) => option.id == saved).toList();
    final initial = valid.isNotEmpty
        ? saved
        : (options.isNotEmpty ? options.first.id : null);
    if (mounted && initial != _selectedId) {
      setState(() => _selectedId = initial);
    }
  }

  Future<void> _select(String optionId) async {
    setState(() => _selectedId = optionId);
    await ServiceLauncher.savePaymentOption(
      catalogId: widget.catalog.id,
      optionId: optionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.catalog.payWith.map((option) {
                final isSelected = option.id == _selectedId;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (_) => _select(option.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colonne compacte du comparateur : les informations essentielles seulement.
class _CompareColumn extends StatelessWidget {
  final OfferModel offer;
  final OperatorTree operator;
  final VoidCallback onLaunch;

  const _CompareColumn({
    required this.offer,
    required this.operator,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${offer.price} FCFA',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: OperatorLogo.accent(context, operator.color),
            ),
          ),
          if (offer.validityLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              offer.validityLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (offer.contents.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...offer.contents
                .take(3)
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $line',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: OperatorLogo.accent(context, operator.color),
                foregroundColor:
                    OperatorLogo.accent(
                          context,
                          operator.color,
                        ).computeLuminance() >
                        0.5
                    ? Colors.black
                    : Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onLaunch,
              child: const Text(
                'Choisir',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
