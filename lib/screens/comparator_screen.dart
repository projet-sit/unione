import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/comparator_service.dart';
import '../models/reseau.dart';
import '../theme/app_theme.dart';
import '../widgets/ussd_flow_screen.dart';

class ComparatorScreen extends StatelessWidget {
  const ComparatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comparisonData = ComparatorService.getComparisonData();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Comparateur de Forfaits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: comparisonData.length,
        itemBuilder: (context, index) {
          final group = comparisonData[index];
          return _buildPriceSection(context, group).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, ComparisonGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '${group.price} FCFA',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: AppTheme.primary.withValues(alpha: 0.3))),
            ],
          ),
        ),
        ...group.bundles.map((bundle) => _buildBundleCard(context, bundle)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBundleCard(BuildContext context, ReseauBundle bundle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bundle.reseau.couleur.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bundle.reseau.couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: bundle.reseau.logo(size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.forfait.data,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Validité : ${bundle.forfait.duree}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UssdFlowScreen(
                      reseau: bundle.reseau,
                      action: bundle.parentAction,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bundle.reseau.couleur,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('ACHETER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
