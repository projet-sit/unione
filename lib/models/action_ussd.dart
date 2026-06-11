import 'forfait.dart';

enum ActionType { information, transfer, credit, bundle, other }

class ActionUssd {
  final String titre;
  final String? sousTitre;
  final dynamic icone; // IconData
  final String? codeBase;
  final String? template;
  final ActionType type;
  final bool aBesoinParam;
  final List<ActionUssd>? sousActions;
  final List<Forfait>? forfaits;

  const ActionUssd({
    required this.titre,
    this.type = ActionType.other,
    this.sousTitre,
    this.icone,
    this.codeBase,
    this.template,
    this.aBesoinParam = false,
    this.sousActions,
    this.forfaits,
  });
}
