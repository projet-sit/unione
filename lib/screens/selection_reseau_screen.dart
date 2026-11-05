import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/history_item.dart';
import '../models/menu_node.dart';
import '../models/reseau.dart';
import '../services/android_ussd_gateway.dart';
import '../services/codes_repository.dart';
import '../services/history_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';
import 'menu_screen.dart';
import 'settings_screen.dart';

class SelectionReseauScreen extends StatefulWidget {
  const SelectionReseauScreen({super.key});
  @override
  State<SelectionReseauScreen> createState() => _SelectionReseauScreenState();
}

class _SelectionReseauScreenState extends State<SelectionReseauScreen> {
  final _history = HistoryService();
  String? _detectedOperator;

  @override
  void initState() {
    super.initState();
    _detectOperator();
  }

  Future<void> _detectOperator() async {
    if (!await Permission.phone.isGranted) return;
    final names = (await AndroidUssdGateway().getSims())
        .map((sim) => '${sim.label} ${sim.operatorName ?? ''}'.toLowerCase()).join(' ');
    final detected = names.contains('mtn') ? 'mtn' : names.contains('moov') ? 'moov' : names.contains('celtiis') ? 'celtiis' : null;
    if (mounted) setState(() => _detectedOperator = detected);
  }

  Future<void> _openOperator(OperatorTree operator) async {
    await _history.logEvent(
      title: 'history_network_title',
      description: 'history_network_selected|${operator.name}',
      network: operator.name,
      type: HistoryType.networkSelection,
    );
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(nodeId: 'operator:${operator.id}')));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: themeNotifier,
    builder: (context, _) => ValueListenableBuilder<UssdTree?>(
      valueListenable: CodesRepository.instance.catalogue,
      builder: (context, tree, _) {
        if (tree == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final operators = [...tree.operators]
          ..sort((a, b) => a.id == _detectedOperator ? -1 : b.id == _detectedOperator ? 1 : 0);
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              children: [
                _header(),
                const SizedBox(height: 36),
                Text('Veuillez sélectionner un réseau :', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                ...operators.map((operator) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ReseauCard(
                    reseau: _toReseau(operator),
                    isDetected: operator.id == _detectedOperator,
                    onTap: () => _openOperator(operator),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: const AppLogo(size: 32)),
        const SizedBox(width: 14),
        Text('UNIONE', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w900)),
      ]),
      IconButton(icon: const Icon(Icons.settings_outlined), tooltip: 'Paramètres', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ],
  );

  Reseau _toReseau(OperatorTree operator) => Reseau(
    type: switch (operator.id) { 'mtn' => ReseauType.mtn, 'moov' => ReseauType.moov, _ => ReseauType.celtiis },
    nom: operator.name,
    couleur: operator.color,
    logoLabel: operator.name.toUpperCase(),
  );
}
