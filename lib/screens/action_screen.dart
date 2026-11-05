import 'package:flutter/material.dart';

import '../models/menu_node.dart';
import '../services/codes_repository.dart';
import '../services/ussd_service.dart';
import 'menu_screen.dart';
import 'selection_reseau_screen.dart';

/// Feuille générique, alimentée exclusivement par un nœud action du JSON.
class ActionScreen extends StatefulWidget {
  final String nodeId;
  const ActionScreen({super.key, required this.nodeId});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  bool _launching = false;

  Future<void> _launch(MenuNode node, OperatorTree operator) async {
    if (node.code == null || node.status != 'ok' || node.params.isNotEmpty) return;
    final needsConfirmation = node.financial || node.destructive;
    if (needsConfirmation) {
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(node.destructive ? 'Confirmer la désactivation' : 'Vérifier l’opération'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(node.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (node.description != null) ...[const SizedBox(height: 8), Text(node.description!)],
            const SizedBox(height: 14), const Text('Code à envoyer :'),
            SelectableText(node.code!, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            const Text('Aucun PIN n’est demandé ni enregistré par UNIONE. Il est saisi seulement dans le dialogue de l’opérateur.'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ANNULER')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('CONFIRMER')),
          ],
        ),
      );
      if (approved != true) return;
    }
    setState(() => _launching = true);
    if (node.launchKind == 'call') {
      await UssdService.launchPhoneNumber(context, node.code!, title: node.label, network: operator.name);
    } else {
      await UssdService.launchUssd(context, node.code!, title: node.label, network: operator.name, operatorId: operator.id);
    }
    if (mounted) setState(() => _launching = false);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UssdTree?>(
    valueListenable: CodesRepository.instance.catalogue,
    builder: (context, tree, _) {
      final node = tree?.node(widget.nodeId);
      final operator = tree?.operatorFor(widget.nodeId);
      if (node == null || operator == null || node.type != MenuNodeType.action) {
        return const Scaffold(body: Center(child: Text('Ce service n’est plus disponible.')));
      }
      final unavailable = node.code == null || node.status != 'ok';
      final path = [operator.name, ...tree!.breadcrumb(widget.nodeId).map((item) => item.label)].join(' › ');
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Détail du service'),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(path, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .48))),
                const SizedBox(height: 22),
                CircleAvatar(radius: 28, backgroundColor: operator.color.withValues(alpha: .12), child: Icon(menuIconFor(node.icon), color: operator.color, size: 28)),
                const SizedBox(height: 18),
                Text(node.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                if (node.description != null) ...[const SizedBox(height: 8), Text(node.description!)],
                if (node.price != null || node.validity != null) ...[
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, children: [if (node.price != null) Chip(label: Text(node.price!)), if (node.validity != null) Chip(label: Text(node.validity!))]),
                ],
                const SizedBox(height: 22),
                if (unavailable)
                  _Notice(text: node.status == 'obsolete' ? 'Ce code est obsolète.' : 'Code bientôt disponible. Vérification en cours.')
                else ...[
                  const Text('Aperçu du code', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  SelectableText(node.code!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
                if (node.notes?.isNotEmpty == true) ...[const SizedBox(height: 16), _Notice(text: node.notes!)],
                const Spacer(),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: operator.color),
                    onPressed: unavailable || node.params.isNotEmpty || _launching ? null : () => _launch(node, operator),
                    icon: _launching ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.phone_forwarded_rounded),
                    label: Text(unavailable ? 'CODE INDISPONIBLE' : node.params.isNotEmpty ? 'INFORMATIONS REQUISES' : node.launchKind == 'call' ? 'APPELER LE SERVICE' : 'LANCER LE CODE'),
                  ),
                ),
                if (node.params.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Center(child: Text('Les informations requises seront demandées avant le lancement.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5), fontSize: 12))),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
