import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/history_item.dart';
import '../models/menu_node.dart';
import '../models/reseau.dart';
import '../services/android_ussd_gateway.dart';
import '../services/codes_repository.dart';
import '../services/history_service.dart';
import '../services/theme_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';
import 'action_screen.dart';
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
  Set<String> _favorites = {};
  List<HistoryItem> _recent = [];
  String? _detectedOperator;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _loadPersonalization();
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _loadPersonalization() async {
    final favorites = await UserPreferencesService.instance.favorites();
    final recent = await _history.getHistory();
    String? detected;
    if (await Permission.phone.isGranted) {
      final names = (await AndroidUssdGateway().getSims()).map((sim) => '${sim.label} ${sim.operatorName ?? ''}'.toLowerCase()).join(' ');
      detected = names.contains('mtn') ? 'mtn' : names.contains('moov') ? 'moov' : names.contains('celtiis') ? 'celtiis' : null;
    }
    if (mounted) setState(() { _favorites = favorites; _recent = recent.where((item) => item.type == HistoryType.ussdLaunch && item.serviceId != null).take(4).toList(); _detectedOperator = detected; });
  }

  Future<void> _openOperator(OperatorTree operator) async {
    await _history.logEvent(title: 'history_network_title', description: 'history_network_selected|${operator.name}', network: operator.name, type: HistoryType.networkSelection);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(nodeId: 'operator:${operator.id}')));
    _loadPersonalization();
  }

  Future<void> _openAction(String id) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ActionScreen(nodeId: id)));
    _loadPersonalization();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: themeNotifier,
    builder: (context, _) => ValueListenableBuilder<UssdTree?>(
      valueListenable: CodesRepository.instance.catalogue,
      builder: (context, tree, _) {
        if (tree == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final query = _search.text.trim().toLowerCase();
        final operators = [...tree.operators]..sort((a, b) => a.id == _detectedOperator ? -1 : b.id == _detectedOperator ? 1 : 0);
        final actions = tree.actions.toList(growable: false);
        final results = query.isEmpty ? const <MenuNode>[] : actions.where((node) => [node.label, node.category ?? '', ...node.keywords].join(' ').toLowerCase().contains(query)).toList();
        final favorites = actions.where((node) => _favorites.contains(node.id)).toList();
        final recentIds = _recent.map((item) => item.serviceId!).toSet();
        final recents = actions.where((node) => recentIds.contains(node.id)).toList();
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 36), children: [
            _header(), const SizedBox(height: 28),
            TextField(controller: _search, decoration: InputDecoration(hintText: 'Rechercher : solde, forfait, internet…', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: query.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: _search.clear), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
            const SizedBox(height: 28),
            if (query.isNotEmpty) ...[_title('Résultats'), _actionList(tree, results, empty: 'Aucune feuille ne correspond à votre recherche.')] else ...[
              if (favorites.isNotEmpty) ...[_title('Favoris'), _actionList(tree, favorites)],
              if (recents.isNotEmpty) ...[_title('Récents'), _actionList(tree, recents)],
              _title('Veuillez sélectionner un réseau :'),
              ...operators.map((operator) => Padding(padding: const EdgeInsets.only(bottom: 16), child: ReseauCard(reseau: _toReseau(operator), isDetected: operator.id == _detectedOperator, onTap: () => _openOperator(operator)))),
            ],
          ])),
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
          return Card(child: ListTile(
            onTap: () => _openAction(node.id),
            leading: CircleAvatar(backgroundColor: operator.color.withValues(alpha: .12), child: Icon(menuIconFor(node.icon), color: operator.color)),
            title: Text(node.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text([operator.name, ...path].join(' › ')),
            trailing: const Icon(Icons.chevron_right_rounded),
          ));
        }).toList()));

  Reseau _toReseau(OperatorTree operator) => Reseau(type: switch (operator.id) { 'mtn' => ReseauType.mtn, 'moov' => ReseauType.moov, _ => ReseauType.celtiis }, nom: operator.name, couleur: operator.color, logoLabel: operator.name.toUpperCase());
}
