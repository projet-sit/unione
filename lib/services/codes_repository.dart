import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_node.dart';

/// Fournit le catalogue embarqué, son cache local et, si configurée, la source HTTPS.
class CodesRepository {
  CodesRepository._();
  static final CodesRepository instance = CodesRepository._();

  static const _cacheKey = 'ussd_tree_v4';
  static const String remoteUrl = String.fromEnvironment('UNIONE_CODES_URL');
  final ValueNotifier<UssdTree?> catalogue = ValueNotifier(null);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        catalogue.value = _decodeAndValidate(cached);
      } on FormatException {
        await prefs.remove(_cacheKey);
      }
    }
    catalogue.value ??= await _readBundled();
    unawaited(refreshInBackground());
  }

  Future<void> refreshInBackground() async {
    if (remoteUrl.isEmpty) return;
    final uri = Uri.tryParse(remoteUrl);
    if (uri == null || uri.scheme != 'https') return;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return;
      final body = await utf8.decoder.bind(response).join();
      final fresh = _decodeAndValidate(body);
      final current = catalogue.value;
      if (current == null || fresh.version >= current.version) {
        catalogue.value = fresh;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, body);
      }
    } catch (_) {
      // Hors ligne ou réponse invalide : le cache déjà affiché reste la référence.
    }
  }

  Future<UssdTree> _readBundled() async => _decodeAndValidate(
    await rootBundle.loadString('assets/data/ussd_tree.json'),
  );

  UssdTree _decodeAndValidate(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON USSD invalide.');
    }
    return UssdTree.fromJson(decoded);
  }
}
