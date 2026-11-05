enum ActionType { information, transfer, credit, bundle, other }

class ActionUssd {
  final String id;
  final String titre;
  final String? sousTitre;
  final dynamic icone; // IconData
  final String? codeBase;
  final String? template;
  final ActionType type;
  final bool aBesoinParam;
  final List<ActionUssd>? sousActions;
  final String category;
  final List<CodeParameter> params;

  const ActionUssd({
    this.id = '',
    required this.titre,
    this.type = ActionType.other,
    this.sousTitre,
    this.icone,
    this.codeBase,
    this.template,
    this.aBesoinParam = false,
    this.sousActions,
    this.category = 'autres',
    this.params = const [],
  });

  bool get requiresParameters => params.isNotEmpty || aBesoinParam;
  String? get executableCode => template ?? codeBase;
}

class CodeParameter {
  final String key;
  final String type;
  final String label;
  final bool sensitive;

  const CodeParameter({
    required this.key,
    required this.type,
    required this.label,
    this.sensitive = false,
  });
}
