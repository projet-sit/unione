import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/ussd_data.dart';
import '../models/action_ussd.dart';
import '../models/reseau.dart';
import '../services/codes_repository.dart';
import '../services/ussd_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/action_tile.dart';
import '../widgets/ussd_flow_screen.dart';

class MenuActionsScreen extends StatefulWidget {
  final Reseau reseau;
  const MenuActionsScreen({super.key, required this.reseau});
  @override
  State<MenuActionsScreen> createState() => _MenuActionsScreenState();
}

class _MenuActionsScreenState extends State<MenuActionsScreen> {
  Set<String> _favorites = {};
  String? _category;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await UserPreferencesService.instance.favorites();
    if (mounted) setState(() => _favorites = favorites);
  }

  Future<void> _toggleFavorite(ActionUssd action) async {
    final added = await UserPreferencesService.instance.toggleFavorite(
      action.id,
    );
    if (!mounted) return;
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${action.titre} ajouté aux favoris.'
              : '${action.titre} retiré des favoris.',
        ),
      ),
    );
  }

  Future<void> _handleAction(ActionUssd action) async {
    HapticFeedback.selectionClick();
    if (action.requiresParameters) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UssdFlowScreen(reseau: widget.reseau, action: action),
        ),
      );
      return;
    }
    final code = action.executableCode;
    if (code == null) return;
    await UssdService.launchUssd(
      context,
      code,
      title: action.titre,
      network: widget.reseau.nom,
      operatorId: widget.reseau.type.name,
    );
  }

  Future<void> _reportCode(ActionUssd action, int version) async {
    final message =
        'Bonjour, je souhaite signaler un code qui ne marche plus.%0A%0AOpérateur : ${widget.reseau.nom}%0AService : ${action.titre}%0ACode : ${action.executableCode ?? 'code à paramètres'}%0AVersion du catalogue : $version%0AVersion de l’app : 1.0.0+2';
    await launchUrl(
      Uri.parse('https://wa.me/22991831317?text=$message'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CodesRepository.instance.catalogue,
      builder: (context, catalogue, _) {
        final actions =
            UssdData.actions[widget.reseau.type] ?? const <ActionUssd>[];
        final categories =
            actions.map((action) => action.category).toSet().toList()..sort();
        final visible = _category == null
            ? actions
            : actions.where((action) => action.category == _category).toList();
        final surface = Theme.of(context).colorScheme.onSurface;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Hero(
              tag: 'logo_${widget.reseau.nom}',
              child: widget.reseau.logo(size: 32),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.reseau.nom} Bénin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: widget.reseau.couleur,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Services disponibles',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: surface,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_categoryName(category)),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: visible.isEmpty
                      ? const Center(
                          child: Text('Aucun service dans cette catégorie.'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final action = visible[index];
                            return ActionTile(
                                  action: action,
                                  reseau: widget.reseau,
                                  isFavorite: _favorites.contains(action.id),
                                  onTap: () => _handleAction(action),
                                  onToggleFavorite: () =>
                                      _toggleFavorite(action),
                                  onReport: catalogue == null
                                      ? null
                                      : () => _reportCode(
                                          action,
                                          catalogue.version,
                                        ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: (index * 45).ms,
                                  duration: 300.ms,
                                )
                                .scale(begin: const Offset(.94, .94));
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryName(String category) => switch (category) {
    'solde' => 'Solde',
    'momo' => 'Mobile money',
    'forfaits' => 'Forfaits',
    'credit' => 'Crédit',
    'compte' => 'Compte',
    _ => category.isEmpty ? 'Autres' : '${category[0].toUpperCase()}${category.substring(1)}',
  };
}
