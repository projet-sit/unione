import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/menu_node.dart';
import '../services/codes_repository.dart';
import '../services/user_preferences_service.dart';
import '../widgets/operation_menu_sheet.dart';
import '../widgets/operator_logo.dart';
import '../widgets/service_launcher.dart';
import 'catalog_screen.dart';
import 'selection_reseau_screen.dart';

/// Affiche n'importe quel nœud de type menu du catalogue JSON.
class MenuScreen extends StatefulWidget {
  final String nodeId;
  const MenuScreen({super.key, required this.nodeId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UssdTree?>(
    valueListenable: CodesRepository.instance.catalogue,
    builder: (context, tree, _) {
      final isOperatorRoot = widget.nodeId.startsWith('operator:');
      final node = isOperatorRoot ? null : tree?.node(widget.nodeId);
      final operator = isOperatorRoot
          ? tree?.operators.where((item) => item.id == widget.nodeId.substring('operator:'.length)).firstOrNull
          : tree?.operatorFor(widget.nodeId);
      if (operator == null || (!isOperatorRoot && (node == null || node.type != MenuNodeType.menu))) {
        return const Scaffold(body: Center(child: Text('Ce menu n’est plus disponible.')));
      }
      final children = isOperatorRoot ? operator.children : node!.children;
      final title = isOperatorRoot ? 'Services disponibles' : node!.label;
      final categories = children.map((child) => child.category).whereType<String>().toSet().toList()..sort();
      final visibleChildren = _category == null ? children : children.where((child) => child.category == _category).toList();
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: _operatorLogo(operator.id),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Accueil',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SelectionReseauScreen()),
                (route) => false,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Breadcrumb(tree: tree!, nodeId: widget.nodeId, operator: operator),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Choisissez un service',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .58)),
              ),
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ChoiceChip(label: const Text('Tous'), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                    const SizedBox(width: 8),
                    ...categories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(label: Text(_categoryName(category)), selected: _category == category, onSelected: (_) => setState(() => _category = category)),
                    )),
                  ]),
                ),
              ],
              const SizedBox(height: 22),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: visibleChildren.length,
                  itemBuilder: (context, index) {
                    final child = visibleChildren[index];
                    return _NodeCard(
                      node: child,
                      color: OperatorLogo.accent(context, operator.color),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        switch (child.type) {
                          case MenuNodeType.menu:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MenuScreen(nodeId: child.id),
                              ),
                            );
                          case MenuNodeType.catalog:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CatalogScreen(
                                  catalogId: child.catalogId ?? child.id,
                                  title: child.label,
                                ),
                              ),
                            );
                          case MenuNodeType.action:
                            ServiceLauncher.launchNode(
                              context,
                              node: child,
                              operator: operator,
                            );
                        }
                      },
                      onLongPress: child.type == MenuNodeType.menu
                          ? null
                          : () async {
                              final favorites = await UserPreferencesService.instance.favorites();
                              if (!context.mounted) return;
                              await OperationMenuSheet.show(
                                context,
                                node: child,
                                operator: operator,
                                tree: tree,
                                favorite: favorites.contains(child.id),
                              );
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  String _categoryName(String category) => switch (category) {
    'solde' => 'Solde',
    'mobile_money' => 'Mobile money',
    'forfaits' => 'Forfaits',
    'credit' => 'Crédit',
    'compte' => 'Compte',
    'fidelite' => 'Fidélité',
    _ => category.isEmpty ? 'Autres' : '${category[0].toUpperCase()}${category.substring(1)}',
  };
}

class _Breadcrumb extends StatelessWidget {
  final UssdTree tree;
  final String nodeId;
  final OperatorTree operator;
  const _Breadcrumb({required this.tree, required this.nodeId, required this.operator});

  @override
  Widget build(BuildContext context) {
    final labels = nodeId.startsWith('operator:')
        ? [operator.name]
        : [operator.name, ...tree.breadcrumb(nodeId).map((node) => node.label)];
    return Text(
      labels.join(' › '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .48),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final MenuNode node;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _NodeCard({required this.node, required this.color, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
                child: Icon(_iconFor(node.icon), color: color, size: 28),
              ),
              const SizedBox(height: 14),
              Text(node.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 15)),
              if (node.type == MenuNodeType.menu) ...[
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded, size: 18, color: color),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

IconData menuIconFor(String icon) => _iconFor(icon);

IconData _iconFor(String icon) => switch (icon) {
  'bank' => Icons.account_balance_outlined,
  'wallet' => Icons.account_balance_wallet_outlined,
  'person' => Icons.person_pin_outlined,
  'grid' => Icons.grid_view_rounded,
  'bag' => Icons.shopping_bag_outlined,
  'time' => Icons.access_time_rounded,
  'flash' => Icons.flash_on_rounded,
  'wifi' => Icons.wifi,
  'phone' => Icons.phone_in_talk,
  'signal' => Icons.signal_cellular_alt_rounded,
  'star' => Icons.star_outline_rounded,
  'support' => Icons.support_agent_rounded,
  'transfer' => Icons.swap_horiz_rounded,
  'payment' => Icons.payments_outlined,
  'credit' => Icons.add_card_rounded,
  'warning' => Icons.warning_amber_rounded,
  _ => Icons.dialpad_rounded,
};

Widget _operatorLogo(String id) =>
    OperatorLogo(operatorId: id, size: 32, borderRadius: 10);
