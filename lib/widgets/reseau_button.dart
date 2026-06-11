import 'package:flutter/material.dart';
import '../models/reseau.dart';

class ReseauButton extends StatelessWidget {
  final Reseau reseau;
  final VoidCallback onTap;

  const ReseauButton({super.key, required this.reseau, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        splashColor: reseau.couleur.withValues(alpha: 0.15),
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            // Fond sombre au lieu de la couleur pleine
            color: const Color(0xFF101C2E),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: reseau.couleur.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: reseau.couleur.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Accent de couleur en point
                  Container(
                    width: 6,
                    height: 40,
                    decoration: BoxDecoration(
                      color: reseau.couleur,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    reseau.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: reseau.couleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: reseau.logo(size: 42),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
