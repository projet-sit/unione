import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';

/// Écran affichant l'historique complet des actions de l'utilisateur.
/// Permet de filtrer par texte, par réseau et par date.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<HistoryItem> _history = [];
  bool _isLoading = true;
  String? _selectedNetwork;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Chargement initial de l'historique au lancement de l'écran.
    _loadHistory();
  }

  /// Charge ou recharge les données de l'historique depuis la base de données.
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _historyService.getHistory(
      query: _searchController.text,
      network: _selectedNetwork,
      startDate: _selectedDate,
      endDate: _selectedDate?.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
    );
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  /// Affiche une boîte de dialogue de confirmation avant d'effacer tout l'historique.
  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('clear_history'.tr(), style: const TextStyle(color: Colors.white)),
        content: Text(
          'clear_history_desc'.tr(),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await _historyService.clearHistory();
              if (context.mounted) {
                Navigator.pop(context);
                _loadHistory(); // Rafraîchissement de la vue.
              }
            },
            child: Text('clear_all'.tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('history_title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Bouton pour effacer l'historique
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: _confirmClearHistory,
            tooltip: 'clear_all'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(), // Zone des filtres (recherche, date, réseau)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AEEF)))
                : _history.isEmpty
                    ? _buildEmptyState() // Vue si aucun résultat
                    : _buildHistoryList(), // Liste des activités
          ),
        ],
      ),
    );
  }

  /// Construit la barre de recherche et les boutons de filtrage.
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Champ de recherche par texte
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'search_placeholder'.tr(),
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => _loadHistory(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Filtre par date
              Expanded(
                child: _buildFilterChip(
                  label: _selectedDate == null 
                      ? 'all_dates'.tr() 
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      _loadHistory();
                    }
                  },
                  onClear: _selectedDate != null ? () {
                    setState(() => _selectedDate = null);
                    _loadHistory();
                  } : null,
                ),
              ),
              const SizedBox(width: 8),
              // Filtre par réseau mobile
              Expanded(
                child: _buildFilterChip(
                  label: _selectedNetwork ?? 'all_networks'.tr(),
                  icon: Icons.cell_tower,
                  onTap: () {
                    _showNetworkPicker();
                  },
                  onClear: _selectedNetwork != null ? () {
                    setState(() => _selectedNetwork = null);
                    _loadHistory();
                  } : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Un bouton de filtre stylisé (chip) avec icône et option de suppression.
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00AEEF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16, color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }

  /// Affiche un sélecteur de réseau dans une feuille modale.
  void _showNetworkPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('select_network_filter'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text('all_networks'.tr(), style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() => _selectedNetwork = null);
              Navigator.pop(context);
              _loadHistory();
            },
          ),
          ...['MTN', 'MOOV', 'CELTIIS'].map((net) => ListTile(
            title: Text(net, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() => _selectedNetwork = net);
              Navigator.pop(context);
              _loadHistory();
            },
          )),
        ],
      ),
    );
  }

  /// Construit la liste des éléments de l'historique groupés par date.
  Widget _buildHistoryList() {
    // Tri pour s'assurer du bon ordre.
    _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Groupement des éléments par titre de section (Aujourd'hui, Hier, Date).
    Map<String, List<HistoryItem>> groupedHistory = {};
    for (var item in _history) {
      final now = DateTime.now();
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      String header;
      if (itemDate == today) {
        header = "today".tr();
      } else if (itemDate == yesterday) {
        header = "yesterday".tr();
      } else {
        header = DateFormat('dd MMMM yyyy', context.locale.toString()).format(itemDate);
      }
      
      if (!groupedHistory.containsKey(header)) {
        groupedHistory[header] = [];
      }
      groupedHistory[header]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final header = groupedHistory.keys.elementAt(index);
        final items = groupedHistory[header]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entête de la section (Date)
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12, top: index == 0 ? 0 : 16),
              child: Text(
                header.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Cartes d'activités pour cette date
            ...items.map((item) => _buildHistoryCard(item)),
          ],
        );
      },
    );
  }

  /// Traduit et formate la description d'un élément d'historique.
  String _getLocalizedDescription(HistoryItem item) {
    if (item.description.contains('|')) {
      final parts = item.description.split('|');
      final key = parts[0];
      final value = parts.length > 1 ? parts[1] : '';
      return key.tr(args: [value]);
    }
    
    // Support pour les anciens formats de description (legacy)
    if (item.description.startsWith("Code lancé : ")) {
      final code = item.description.replaceFirst("Code lancé : ", "");
      return "history_ussd_executed".tr(args: [code]);
    }
    if (item.description.startsWith("Code lancé: ")) {
      final code = item.description.replaceFirst("Code lancé: ", "");
      return "history_ussd_executed".tr(args: [code]);
    }
    if (item.description.startsWith("Choix de l'opérateur ")) {
      final operator = item.description.replaceFirst("Choix de l'opérateur ", "");
      return "history_network_selected".tr(args: [operator]);
    }
    
    return item.description.tr();
  }

  /// Construit une carte individuelle pour un événement de l'historique.
  Widget _buildHistoryCard(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône indicatrice du type d'action
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(item.type).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Titre de l'action
                    Text(
                      item.title.tr(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // Heure de l'action
                    Text(
                      DateFormat('HH:mm').format(item.timestamp),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Description détaillée
                Text(
                  _getLocalizedDescription(item),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                // Badge du réseau si applicable
                if (item.network != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.network!,
                      style: const TextStyle(color: Color(0xFF00AEEF), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  /// Vue affichée quand aucun historique n'est disponible ou trouvé.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'no_history'.tr(),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 18),
          ),
        ],
      ),
    );
  }

  /// Retourne l'icône correspondante à chaque type d'activité.
  IconData _getTypeIcon(HistoryType type) {
    switch (type) {
      case HistoryType.networkSelection: return Icons.cell_tower;
      case HistoryType.ussdLaunch: return Icons.phone_forwarded;
      case HistoryType.search: return Icons.search;
      case HistoryType.favoriteAdd: return Icons.favorite;
      case HistoryType.favoriteRemove: return Icons.favorite_border;
      case HistoryType.navigation: return Icons.explore;
      default: return Icons.info_outline;
    }
  }

  /// Retourne la couleur thématique pour chaque type d'activité.
  Color _getTypeColor(HistoryType type) {
    switch (type) {
      case HistoryType.ussdLaunch: return const Color(0xFF00AEEF);
      case HistoryType.networkSelection: return Colors.orangeAccent;
      case HistoryType.favoriteAdd: return Colors.pinkAccent;
      case HistoryType.favoriteRemove: return Colors.grey;
      case HistoryType.search: return Colors.blueAccent;
      default: return Colors.white54;
    }
  }
}
