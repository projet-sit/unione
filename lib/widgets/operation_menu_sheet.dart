import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/menu_node.dart';
import '../services/user_preferences_service.dart';
import '../services/whatsapp_launcher.dart';
import 'operator_logo.dart';

/// Feuille ouverte par un appui long sur une opération (menus, recherche, favoris) :
/// ajouter/retirer des favoris et signaler un code qui ne marche plus.
/// Le code USSD n'est jamais affiché dans l'app : il figure uniquement
/// dans le message WhatsApp prérempli du signalement.
class OperationMenuSheet extends StatefulWidget {
  final MenuNode node;
  final OperatorTree operator;
  final UssdTree tree;
  final bool favorite;

  const OperationMenuSheet({
    super.key,
    required this.node,
    required this.operator,
    required this.tree,
    required this.favorite,
  });

  /// Ouvre la feuille. Retourne le nouvel état du favori si l'utilisateur en a
  /// changé, sinon null (fermeture simple ou signalement).
  static Future<bool?> show(
    BuildContext context, {
    required MenuNode node,
    required OperatorTree operator,
    required UssdTree tree,
    required bool favorite,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => OperationMenuSheet(
        node: node,
        operator: operator,
        tree: tree,
        favorite: favorite,
      ),
    );
  }

  @override
  State<OperationMenuSheet> createState() => _OperationMenuSheetState();
}

class _OperationMenuSheetState extends State<OperationMenuSheet> {
  late final bool _favorite = widget.favorite;

  Future<void> _toggleFavorite() async {
    final newState = await UserPreferencesService.instance.toggleFavorite(
      widget.node.id,
    );
    if (!mounted) return;
    Navigator.pop(context, newState);
  }

  Future<void> _report() async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, null);
    final path = [
      widget.operator.name,
      ...widget.tree.breadcrumb(widget.node.id).map((item) => item.label),
    ].join(' › ');
    final status = await WhatsAppLauncher.open(
      message: AppConfig.reportCodeMessage(
        operatorName: widget.operator.name,
        path: path,
        service: widget.node.label,
        code: widget.node.code,
        treeVersion: '${widget.tree.version}',
      ),
    );
    WhatsAppLauncher.notify(messenger, status);
  }

  @override
  Widget build(BuildContext context) {
    final path = [
      widget.operator.name,
      ...widget.tree.breadcrumb(widget.node.id).map((item) => item.label),
    ].join(' › ');
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: OperatorLogo.accent(
                    context,
                    widget.operator.color,
                  ).withValues(alpha: .15),
                  child: Icon(
                    Icons.dialpad_rounded,
                    color: OperatorLogo.accent(context, widget.operator.color),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.node.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _favorite ? Colors.amber : null,
            ),
            title: Text(
              _favorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            ),
            onTap: _toggleFavorite,
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Signaler un code qui ne marche plus'),
            onTap: _report,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
