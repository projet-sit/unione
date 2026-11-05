import 'package:flutter/material.dart';

enum MenuNodeType { menu, action }

class CodeParameter {
  final String key;
  final String type;
  final String label;
  final String? format;
  final List<String> options;
  final String? notes;

  const CodeParameter({
    required this.key,
    required this.type,
    required this.label,
    this.format,
    this.options = const [],
    this.notes,
  });

  factory CodeParameter.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';
    final label = json['label']?.toString() ?? '';
    if (key.isEmpty || type.isEmpty || label.isEmpty || key.toLowerCase().contains('pin')) {
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
      options: List<String>.from((options ?? const []).map((item) => item.toString())),
      notes: json['notes']?.toString(),
    );
  }
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
  final List<MenuNode> children;

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
    this.children = const [],
  });

  bool get isAvailable => type == MenuNodeType.action && code != null && status == 'ok';

  factory MenuNode.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final rawType = json['type']?.toString();
    final type = switch (rawType) {
      'menu' => MenuNodeType.menu,
      'action' => MenuNodeType.action,
      _ => null,
    };
    final label = json['label']?.toString() ?? '';
    final icon = json['icon']?.toString() ?? 'dialpad';
    final status = json['status']?.toString() ?? '';
    final confidence = json['confidence']?.toString() ?? '';
    final rawChildren = json['children'];
    final rawParams = json['params'];
    if (id.isEmpty || type == null || label.isEmpty ||
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
    if (code is String && RegExp(r'\{[^}]*pin[^}]*\}', caseSensitive: false).hasMatch(code)) {
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
    if (type == MenuNodeType.menu && (children.isEmpty || code != null || params.isNotEmpty)) {
      throw const FormatException('Un menu doit uniquement contenir des enfants.');
    }
    if (type == MenuNodeType.action && (children.isNotEmpty || (code == null && status != 'a_verifier'))) {
      throw const FormatException('Action USSD invalide.');
    }
    return MenuNode(
      id: id,
      type: type,
      label: label,
      icon: icon,
      category: json['category']?.toString(),
      keywords: List<String>.from(((json['keywords'] as List?) ?? const []).map((item) => item.toString())),
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
      children: children,
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
    if (id.isEmpty || name.isEmpty || country.isEmpty || rootCode.isEmpty || color == null || children is! List || children.isEmpty) {
      throw const FormatException('Opérateur USSD incomplet.');
    }
    return OperatorTree(
      id: id,
      name: name,
      country: country,
      color: color,
      rootCode: rootCode,
      children: children.map((child) {
        if (child is! Map<String, dynamic>) throw const FormatException('Enfant opérateur invalide.');
        return MenuNode.fromJson(child);
      }).toList(growable: false),
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

  UssdTree({required this.version, required this.updatedAt, required this.operators}) {
    _nodes = {};
    _operatorByNode = {};
    _parents = {};
    for (final operator in operators) {
      for (final child in operator.children) {
        _index(child, operator, null, <String>{});
      }
    }
  }

  void _index(MenuNode node, OperatorTree operator, String? parentId, Set<String> ancestors) {
    if (_nodes.containsKey(node.id)) throw FormatException('ID USSD dupliqué : ${node.id}');
    if (ancestors.contains(node.id)) throw FormatException('Cycle USSD détecté : ${node.id}');
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
  Iterable<MenuNode> get actions => _nodes.values.where((node) => node.type == MenuNodeType.action);

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
    if (version is! int || version < 1 || updatedAt == null || operators is! List || operators.isEmpty) {
      throw const FormatException('Arbre USSD invalide.');
    }
    final parsed = operators.map((operator) {
      if (operator is! Map<String, dynamic>) throw const FormatException('Opérateur invalide.');
      return OperatorTree.fromJson(operator);
    }).toList(growable: false);
    final ids = parsed.map((operator) => operator.id).toSet();
    if (ids.length != parsed.length) throw const FormatException('ID opérateur dupliqué.');
    return UssdTree(version: version, updatedAt: updatedAt, operators: parsed);
  }
}
