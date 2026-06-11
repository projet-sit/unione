import 'package:flutter/material.dart';
import '../widgets/logos/celtiis_logo.dart';
import '../widgets/logos/moov_logo.dart';
import '../widgets/logos/mtn_logo.dart';

enum ReseauType { mtn, moov, celtiis }

class Reseau {
  final ReseauType type;
  final String nom;
  final Color couleur;
  final String logoLabel; // Identifiant texte conservé pour les métadonnées.

  const Reseau({
    required this.type,
    required this.nom,
    required this.couleur,
    required this.logoLabel,
  });
}

extension ReseauLogo on Reseau {
  Widget logo({double size = 44}) {
    switch (type) {
      case ReseauType.mtn:
        return MtnLogo(size: size);
      case ReseauType.moov:
        return MoovLogo(size: size);
      case ReseauType.celtiis:
        return CeltiisLogo(size: size);
    }
  }
}
