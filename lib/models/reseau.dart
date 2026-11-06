import 'package:flutter/material.dart';
import '../widgets/operator_logo.dart';

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
  Widget logo({double size = 44, double? borderRadius}) {
    return OperatorLogo(
      operatorId: type.name,
      size: size,
      borderRadius: borderRadius,
    );
  }
}
