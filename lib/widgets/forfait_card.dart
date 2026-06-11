import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../models/forfait.dart';

class ForfaitCard extends StatelessWidget {
  final Forfait forfait;
  final Reseau reseau;
  final VoidCallback onTap;

  const ForfaitCard({
    super.key, 
    required this.forfait, 
    required this.reseau, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    forfait.prix,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: reseau.couleur,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        forfait.data,
                        style: TextStyle(
                          color: reseau.type == ReseauType.mtn ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        forfait.duree,
                        style: TextStyle(
                          color: reseau.type == ReseauType.mtn ? Colors.black87 : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
