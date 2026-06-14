import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
import 'forfaits_screen.dart';

/// Écran affichant les catégories de forfaits pour un réseau donné (ex: Internet, Appel, Mixte).
class ForfaitCategoriesScreen extends StatelessWidget {
  /// Le réseau mobile sélectionné.
  final Reseau reseau;
  /// L'action parente (généralement "Forfait") contenant les sous-catégories.
  final ActionUssd parentAction;

  const ForfaitCategoriesScreen({
    super.key,
    required this.reseau,
    required this.parentAction,
  });

  @override
  Widget build(BuildContext context) {
    // Récupération des sous-actions (catégories) définies dans UssdData.
    final categories = parentAction.sousActions ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppLogo.small(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ReseauHeader(reseau: reseau)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de l'écran (ex: Forfait)
            Text(
              parentAction.titre.tr(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Instruction pour l'utilisateur
            Text(
              'Choisissez le type de forfait que vous souhaitez souscrire.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            // Grille des catégories de forfaits
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _buildCategoryCard(context, cat, index, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une carte interactive pour chaque catégorie de forfait.
  Widget _buildCategoryCard(BuildContext context, ActionUssd category, int index, bool isDark) {
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02);
    final borderCol = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08);

    return InkWell(
      onTap: () {
        // Navigation vers l'écran des forfaits de cette catégorie.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForfaitsScreen(
              reseau: reseau,
              parentAction: category,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icône de la catégorie
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: reseau.couleur.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icone ?? Icons.widgets_outlined,
                color: reseau.couleur,
                size: 26,
              ),
            ),
            // Titre de la catégorie
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.titre.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 350.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: (index * 80).ms,
          duration: 350.ms,
          curve: Curves.easeOutBack,
        );
  }
}
