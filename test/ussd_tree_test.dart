import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unione/models/menu_node.dart';

void main() {
  test('l’arbre USSD embarqué est cohérent', () async {
    final raw = await File('assets/data/ussd_tree.json').readAsString();
    final tree = UssdTree.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    final ids = <String>{};
    for (final action in tree.actions) {
      expect(ids.add(action.id), isTrue);
      expect(action.code != null || action.status == 'a_verifier', isTrue,
          reason: '${action.id} doit avoir un code ou être à vérifier');
    }
    expect(tree.operators, isNotEmpty);
    expect(tree.actions, isNotEmpty);
  });
}
