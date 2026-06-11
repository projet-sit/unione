import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';

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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _historyService.getHistory(
      query: _searchController.text,
      network: _selectedNetwork,
      startDate: _selectedDate,
      endDate: _selectedDate != null 
          ? _selectedDate!.add(const Duration(hours: 23, minutes: 59, seconds: 59)) 
          : null,
    );
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Effacer l\'historique ?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Cette action est irréversible. Toutes vos données locales seront supprimées.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await _historyService.clearHistory();
              if (mounted) {
                Navigator.pop(context);
                _loadHistory();
              }
            },
            child: const Text('EFFACER TOUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      appBar: AppBar(
        title: const Text('Mon Historique'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: _confirmClearHistory,
            tooltip: 'Effacer tout',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AEEF)))
                : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher...',
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
              Expanded(
                child: _buildFilterChip(
                  label: _selectedDate == null 
                      ? 'Toutes les dates' 
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
              Expanded(
                child: _buildFilterChip(
                  label: _selectedNetwork ?? 'Tous les réseaux',
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

  void _showNetworkPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Sélectionner un réseau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Tous les réseaux', style: TextStyle(color: Colors.white)),
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

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryCard(item);
      },
    );
  }

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
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateFormat('HH:mm').format(item.timestamp),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
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
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy', 'fr_FR').format(item.timestamp),
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'Aucun historique trouvé',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 18),
          ),
        ],
      ),
    );
  }

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
