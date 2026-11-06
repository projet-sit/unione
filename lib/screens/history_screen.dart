import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../widgets/skeleton_loader.dart';

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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 20;

  String? _selectedNetwork;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });
    final history = await _historyService.getHistory(
      query: _searchController.text,
      network: _selectedNetwork,
      startDate: _selectedDate,
      endDate: _selectedDate?.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      ),
      limit: _pageSize,
      offset: 0,
    );
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
        _hasMore = history.length == _pageSize;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final more = await _historyService.getHistory(
      query: _searchController.text,
      network: _selectedNetwork,
      startDate: _selectedDate,
      endDate: _selectedDate?.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      ),
      limit: _pageSize,
      offset: _history.length,
    );
    if (mounted) {
      setState(() {
        _history.addAll(more);
        _isLoadingMore = false;
        _hasMore = more.length == _pageSize;
      });
    }
  }

  void _confirmClearHistory() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'clear_history'.tr(),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'clear_history_desc'.tr(),
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _historyService.clearHistory();
              if (context.mounted) {
                Navigator.pop(context);
                _loadHistory();
              }
            },
            child: Text(
              'clear_all'.tr(),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('history_title'.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.redAccent,
            ),
            onPressed: _confirmClearHistory,
            tooltip: 'clear_all'.tr(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? _buildSkeletonList()
                : _history.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'search_placeholder'.tr(),
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.primary,
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (value) => _loadHistory(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: _selectedDate == null
                      ? 'all_dates'.tr()
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  icon: Icons.calendar_today_rounded,
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
                  onClear: _selectedDate != null
                      ? () {
                          setState(() => _selectedDate = null);
                          _loadHistory();
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  label: _selectedNetwork ?? 'all_networks'.tr(),
                  icon: Icons.cell_tower_rounded,
                  onTap: () {
                    _showNetworkPicker();
                  },
                  onClear: _selectedNetwork != null
                      ? () {
                          setState(() => _selectedNetwork = null);
                          _loadHistory();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = onClear != null;
    final hint = isSelected ? 'Appuyez pour changer, filtre actif : $label' : label;
    return Semantics(
      label: hint,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 16, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onClear != null)
                Semantics(
                  label: 'Effacer le filtre',
                  button: true,
                  child: GestureDetector(
                    onTap: onClear,
                    child: ExcludeSemantics(
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNetworkPicker() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'select_network_filter'.tr(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.grid_view_rounded,
                color: colorScheme.primary,
              ),
              title: Text(
                'all_networks'.tr(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                setState(() => _selectedNetwork = null);
                Navigator.pop(context);
                _loadHistory();
              },
            ),
            ...['MTN', 'MOOV', 'CELTIIS'].map(
              (net) => ListTile(
                leading: Icon(
                  Icons.cell_tower_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  net,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  setState(() => _selectedNetwork = net);
                  Navigator.pop(context);
                  _loadHistory();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Affiche un skeleton animé pendant le chargement de l'historique.
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      itemBuilder: (_, _) => const SkeletonHistoryCard(),
    );
  }

  Widget _buildHistoryList() {
    _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    Map<String, List<HistoryItem>> groupedHistory = {};
    for (var item in _history) {
      final now = DateTime.now();
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      String header;
      if (itemDate == today) {
        header = "today".tr();
      } else if (itemDate == yesterday) {
        header = "yesterday".tr();
      } else {
        String localeStr;
        try {
          localeStr = context.locale.toString();
        } catch (_) {
          localeStr = 'fr_FR';
        }
        header = DateFormat(
          'dd MMMM yyyy',
          localeStr,
        ).format(itemDate);
      }

      if (!groupedHistory.containsKey(header)) {
        groupedHistory[header] = [];
      }
      groupedHistory[header]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: groupedHistory.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Dernier item = bouton "Charger plus"
        if (index == groupedHistory.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.expand_more_rounded),
                      label: const Text('Charger plus'),
                    ),
            ),
          );
        }
        final header = groupedHistory.keys.elementAt(index);
        final items = groupedHistory[header]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 4,
                bottom: 16,
                top: index == 0 ? 0 : 24,
              ),
              child: Text(
                header.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...items.map((item) => _buildHistoryCard(item)),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(item.type);
    final timeStr = DateFormat('HH:mm').format(item.timestamp);
    final networkPart = item.network != null ? ', réseau ${item.network}' : '';
    final semanticLabel =
        '${item.title.tr()}, ${_getLocalizedDescription(item)}$networkPart, à $timeStr';

    return Semantics(
          label: semanticLabel,
          excludeSemantics: true,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getTypeIcon(item.type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title.tr(),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getLocalizedDescription(item),
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.network != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.network!,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 20),
          Text(
            'no_history'.tr(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Formate la description de l'historique pour l'affichage localisé.
  String _getLocalizedDescription(HistoryItem item) {
    if (item.description.startsWith('history_ussd_executed')) {
      return 'history_ussd_executed'.tr();
    }
    return item.description.tr();
  }

  /// Retourne l'icône correspondante à chaque type d'activité.
  IconData _getTypeIcon(HistoryType type) {
    switch (type) {
      case HistoryType.networkSelection:
        return Icons.cell_tower_rounded;
      case HistoryType.ussdLaunch:
        return Icons.phone_forwarded_rounded;
      case HistoryType.search:
        return Icons.search_rounded;
      case HistoryType.navigation:
        return Icons.explore_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// Retourne la couleur thématique pour chaque type d'activité.
  Color _getTypeColor(HistoryType type) {
    switch (type) {
      case HistoryType.ussdLaunch:
        return Theme.of(context).colorScheme.primary;
      case HistoryType.networkSelection:
        return Colors.orangeAccent;
      case HistoryType.search:
        return Colors.blueAccent;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }
}
