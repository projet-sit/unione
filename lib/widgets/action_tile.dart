import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';

class ActionTile extends StatelessWidget {
  final ActionUssd action;
  final Reseau reseau;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onReport;
  final bool isFavorite;

  const ActionTile({
    super.key,
    required this.action,
    required this.reseau,
    required this.onTap,
    this.onToggleFavorite,
    this.onReport,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onToggleFavorite,
          borderRadius: BorderRadius.circular(24),
          splashColor: reseau.couleur.withValues(alpha: 0.1),
          highlightColor: reseau.couleur.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: onReport,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.report_problem_outlined,
                          color: onSurfaceColor.withValues(alpha: 0.25),
                          size: 18,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onToggleFavorite,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFavorite
                              ? Colors.amber
                              : onSurfaceColor.withValues(alpha: 0.25),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reseau.couleur.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icone as IconData,
                    size: 28,
                    color: reseau.couleur,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  action.titre.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
