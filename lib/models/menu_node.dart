import 'package:flutter/material.dart';

enum MenuNodeType { menu, action, catalog, flow }

class CodeParameter {
  final String key;
  final String type;
  final String label;
  final String? format;
  final int? min;
  final int? max;
  final List<String> options;
  final String? notes;

  const CodeParameter({
    required this.key,
    required this.type,
    required this.label,
    this.format,
    this.min,
    this.max,
    this.options = const [],
    this.notes,
  });

  factory CodeParameter.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';
    final label = json['label']?.toString() ?? '';
    if (key.isEmpty ||
        type.isEmpty ||
        label.isEmpty ||
        key.toLowerCase().contains('pin')) {
      throw const FormatException('Paramètre USSD invalide.');
    }
    final options = json['options'];
    if (options != null && options is! List) {
      throw const FormatException('Options de paramètre invalides.');
    }
    return CodeParameter(
      key: key,
      type: type,
      label: label,
      format: json['format']?.toString(),
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
      options: List<String>.from(
        (options ?? const []).map((item) => item.toString()),
      ),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'type': type,
    'label': label,
    if (format != null) 'format': format,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (options.isNotEmpty) 'options': options,
    if (notes != null) 'notes': notes,
  };
}

/// Étape d'un parcours guidé (ex. type, pour qui).
class FlowStep {
  final String key;
  final String label;
  final List<FlowOption> options;

  const FlowStep({
    required this.key,
    required this.label,
    required this.options,
  });

  factory FlowStep.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = (rawOptions is List ? rawOptions : const [])
        .whereType<Map<String, dynamic>>()
        .map(FlowOption.fromJson)
        .toList(growable: false);
    return FlowStep(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      options: options,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

/// Option d'une étape du parcours guidé.
class FlowOption {
  final String id;
  final String label;

  const FlowOption({required this.id, required this.label});

  factory FlowOption.fromJson(Map<String, dynamic> json) {
    return FlowOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label};
}

/// Variante d'une action (pour soi / pour un autre).
class FlowVariant {
  final String? code;
  final List<CodeParameter> params;

  const FlowVariant({this.code, this.params = const []});

  factory FlowVariant.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    final params = (rawParams is List ? rawParams : const [])
        .whereType<Map<String, dynamic>>()
        .map(CodeParameter.fromJson)
        .toList(growable: false);
    return FlowVariant(code: json['code']?.toString(), params: params);
  }

  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (params.isNotEmpty) 'params': params.map((p) => p.toJson()).toList(),
  };
}

/// Action déclenchée à la fin d'un parcours guidé.
class FlowAction {
  final String id;
  final String type; // 'internet', 'appel', 'transfert'
  final FlowVariant? moi;
  final FlowVariant? autre;

  const FlowAction({
    required this.id,
    required this.type,
    this.moi,
    this.autre,
  });

  factory FlowAction.fromJson(Map<String, dynamic> json) {
    return FlowAction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      moi: json['moi'] is Map<String, dynamic>
          ? FlowVariant.fromJson(json['moi'] as Map<String, dynamic>)
          : null,
      autre: json['autre'] is Map<String, dynamic>
          ? FlowVariant.fromJson(json['autre'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (moi != null) 'moi': moi!.toJson(),
    if (autre != null) 'autre': autre!.toJson(),
  };
}

class MenuNode {
  final String id;
  final MenuNodeType type;
  final String label;
  final String icon;
  final String? category;
  final List<String> keywords;
  final String? description;
  final String? price;
  final String? validity;
  final String? code;
  final String? launchKind;
  final List<CodeParameter> params;
  final bool financial;
  final bool destructive;
  final String status;
  final String confidence;
  final String? source;
  final String? alt;
  final String? notes;
  final String? catalogId;
  final List<MenuNode> children;

  /// Pour un nœud de type flow : étapes du parcours guidé (type, pour qui, etc.)
  final List<FlowStep>? steps;

  /// Pour un nœud de type flow : actions disponibles à la dernière étape.
  final List<FlowAction>? actions;

  const MenuNode({
    required this.id,
    required this.type,
    required this.label,
    required this.icon,
    this.category,
    this.keywords = const [],
    this.description,
    this.price,
    this.validity,
    this.code,
    this.launchKind,
    this.params = const [],
    this.financial = false,
    this.destructive = false,
    required this.status,
    required this.confidence,
    this.source,
    this.alt,
    this.notes,
    this.catalogId,
    this.children = const [],
    this.steps,
    this.actions,
  });

  bool get isAvailable =>
      (type == MenuNodeType.action && code != null && status == 'ok') ||
      (type == MenuNodeType.catalog && catalogId != null && status == 'ok') ||
      (type == MenuNodeType.flow &&
          status == 'ok' &&
          actions != null &&
          actions!.isNotEmpty);

  factory MenuNode.fromJson(Map<String, dynamic> json) {
    final catalogId = json['catalogId']?.toString();
    final id = json['id']?.toString() ?? catalogId ?? '';
    final rawType = json['type']?.toString();
    final type = switch (rawType) {
      'menu' => MenuNodeType.menu,
      'action' => MenuNodeType.action,
      'catalog' => MenuNodeType.catalog,
      'flow' => MenuNodeType.flow,
      _ => null,
    };
    final label = json['label']?.toString() ?? '';
    final icon = json['icon']?.toString() ?? 'dialpad';
    final status = json['status']?.toString() ?? 'ok';
    final confidence = json['confidence']?.toString() ?? 'high';
    final rawChildren = json['children'];
    final rawParams = json['params'];
    if (id.isEmpty ||
        type == null ||
        label.isEmpty ||
        !const {'ok', 'a_verifier', 'obsolete'}.contains(status) ||
        !const {'high', 'medium', 'low'}.contains(confidence) ||
        (rawChildren != null && rawChildren is! List) ||
        (rawParams != null && rawParams is! List)) {
      throw const FormatException('Nœud USSD incomplet ou invalide.');
    }
    final code = json['code'];
    if (code != null && code is! String) {
      throw const FormatException('Code USSD invalide.');
    }
    if (code is String &&
        RegExp(r'\{[^}]*pin[^}]*\}', caseSensitive: false).hasMatch(code)) {
      throw const FormatException('Un code ne doit jamais contenir de PIN.');
    }
    final children = (rawChildren as List? ?? const [])
        .map((child) {
          if (child is! Map<String, dynamic>) {
            throw const FormatException('Enfant USSD invalide.');
          }
          return MenuNode.fromJson(child);
        })
        .toList(growable: false);
    final params = (rawParams as List? ?? const [])
        .map((param) {
          if (param is! Map<String, dynamic>) {
            throw const FormatException('Paramètre USSD invalide.');
          }
          return CodeParameter.fromJson(param);
        })
        .toList(growable: false);
    final steps = (json['steps'] as List? ?? const [])
        .map((step) {
          if (step is! Map<String, dynamic>) {
            throw const FormatException('Étape de flow invalide.');
          }
          return FlowStep.fromJson(step);
        })
        .toList(growable: false);
    final actions = (json['actions'] as List? ?? const [])
        .map((action) {
          if (action is! Map<String, dynamic>) {
            throw const FormatException('Action de flow invalide.');
          }
          return FlowAction.fromJson(action);
        })
        .toList(growable: false);
    if (type == MenuNodeType.menu &&
        (children.isEmpty || code != null || params.isNotEmpty)) {
      throw const FormatException(
        'Un menu doit uniquement contenir des enfants.',
      );
    }
    if (type == MenuNodeType.action &&
        (children.isNotEmpty || (code == null && status != 'a_verifier'))) {
      throw const FormatException('Action USSD invalide.');
    }
    if (type == MenuNodeType.catalog &&
        (catalogId == null || catalogId.isEmpty || children.isNotEmpty)) {
      throw const FormatException('Nœud catalogue USSD invalide.');
    }
    if (type == MenuNodeType.flow && (steps.isEmpty || actions.isEmpty)) {
      throw const FormatException(
        'Un nœud flow doit avoir des étapes et des actions.',
      );
    }
    return MenuNode(
      id: id,
      type: type,
      label: label,
      icon: icon,
      category: json['category']?.toString(),
      keywords: List<String>.from(
        ((json['keywords'] as List?) ?? const []).map(
          (item) => item.toString(),
        ),
      ),
      description: json['description']?.toString(),
      price: json['price']?.toString(),
      validity: json['validity']?.toString(),
      code: code as String?,
      launchKind: json['launchKind']?.toString(),
      params: params,
      financial: json['financial'] == true,
      destructive: json['destructive'] == true,
      status: status,
      confidence: confidence,
      source: json['source']?.toString(),
      alt: json['alt']?.toString(),
      notes: json['notes']?.toString(),
      catalogId: catalogId,
      children: children,
      steps: steps,
      actions: actions,
    );
  }
}

class OperatorTree {
  final String id;
  final String name;
  final String country;
  final Color color;
  final String rootCode;
  final List<MenuNode> children;

  const OperatorTree({
    required this.id,
    required this.name,
    required this.country,
    required this.color,
    required this.rootCode,
    required this.children,
  });

  factory OperatorTree.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    final rootCode = json['rootCode']?.toString() ?? '';
    final color = _parseColor(json['color']?.toString());
    final children = json['children'];
    if (id.isEmpty ||
        name.isEmpty ||
        country.isEmpty ||
        rootCode.isEmpty ||
        color == null ||
        children is! List ||
        children.isEmpty) {
      throw const FormatException('Opérateur USSD incomplet.');
    }
    return OperatorTree(
      id: id,
      name: name,
      country: country,
      color: color,
      rootCode: rootCode,
      children: children
          .map((child) {
            if (child is! Map<String, dynamic>) {
              throw const FormatException('Enfant opérateur invalide.');
            }
            return MenuNode.fromJson(child);
          })
          .toList(growable: false),
    );
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
    return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
  }
}

class UssdTree {
  final int version;
  final DateTime updatedAt;
  final List<OperatorTree> operators;
  late final Map<String, MenuNode> _nodes;
  late final Map<String, OperatorTree> _operatorByNode;
  late final Map<String, String?> _parents;

  UssdTree({
    required this.version,
    required this.updatedAt,
    required this.operators,
  }) {
    _nodes = {};
    _operatorByNode = {};
    _parents = {};
    for (final operator in operators) {
      for (final child in operator.children) {
        _index(child, operator, null, <String>{});
      }
    }
  }

  void _index(
    MenuNode node,
    OperatorTree operator,
    String? parentId,
    Set<String> ancestors,
  ) {
    if (_nodes.containsKey(node.id)) {
      throw FormatException('ID USSD dupliqué : ${node.id}');
    }
    if (ancestors.contains(node.id)) {
      throw FormatException('Cycle USSD détecté : ${node.id}');
    }
    _nodes[node.id] = node;
    _operatorByNode[node.id] = operator;
    _parents[node.id] = parentId;
    final nextAncestors = {...ancestors, node.id};
    for (final child in node.children) {
      _index(child, operator, node.id, nextAncestors);
    }
  }

  MenuNode? node(String id) => _nodes[id];
  OperatorTree? operatorFor(String id) => _operatorByNode[id];
  Iterable<MenuNode> get actions =>
      _nodes.values.where((node) => node.type == MenuNodeType.action);
  Iterable<MenuNode> get catalogs =>
      _nodes.values.where((node) => node.type == MenuNodeType.catalog);
  Iterable<MenuNode> get flows =>
      _nodes.values.where((node) => node.type == MenuNodeType.flow);
  Iterable<MenuNode> get searchableNodes => _nodes.values.where(
    (node) =>
        node.type == MenuNodeType.action ||
        node.type == MenuNodeType.catalog ||
        node.type == MenuNodeType.flow,
  );

  List<MenuNode> breadcrumb(String id) {
    final result = <MenuNode>[];
    String? current = id;
    while (current != null) {
      final node = _nodes[current];
      if (node == null) break;
      result.insert(0, node);
      current = _parents[current];
    }
    return result;
  }

  factory UssdTree.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    final operators = json['operators'];
    if (version is! int ||
        version < 1 ||
        updatedAt == null ||
        operators is! List ||
        operators.isEmpty) {
      throw const FormatException('Arbre USSD invalide.');
    }
    final parsed = operators
        .map((operator) {
          if (operator is! Map<String, dynamic>) {
            throw const FormatException('Opérateur invalide.');
          }
          return OperatorTree.fromJson(operator);
        })
        .toList(growable: false);
    final ids = parsed.map((operator) => operator.id).toSet();
    if (ids.length != parsed.length) {
      throw const FormatException('ID opérateur dupliqué.');
    }
    return UssdTree(version: version, updatedAt: updatedAt, operators: parsed);
  }
}
