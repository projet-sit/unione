import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/catalog_model.dart';
import '../models/menu_node.dart';

/// Fournit le catalogue embarqué, son cache local et, si configurée, la source HTTPS.
class CodesRepository {
  CodesRepository._();
  static final CodesRepository instance = CodesRepository._();

  static const _cacheKey = 'ussd_tree_v4';
  static const _catalogsCacheKey = 'catalogs_v1';
  static const String remoteUrl = String.fromEnvironment('UNIONE_CODES_URL');
  static const String remoteCatalogsUrl = String.fromEnvironment('UNIONE_CATALOGS_URL');

  final ValueNotifier<UssdTree?> catalogue = ValueNotifier(null);
  final ValueNotifier<CatalogsData?> catalogs = ValueNotifier(null);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Chargement de l'arbre USSD
    final cachedTree = prefs.getString(_cacheKey);
    if (cachedTree != null) {
      try {
        catalogue.value = _decodeAndValidateTree(cachedTree);
      } on FormatException {
        await prefs.remove(_cacheKey);
      }
    }
    catalogue.value ??= await _readBundledTree();

    // 2. Chargement des catalogues de forfaits
    final cachedCatalogs = prefs.getString(_catalogsCacheKey);
    if (cachedCatalogs != null) {
      try {
        catalogs.value = _decodeAndValidateCatalogs(cachedCatalogs);
      } on FormatException {
        await prefs.remove(_catalogsCacheKey);
      }
    }
    catalogs.value ??= await _readBundledCatalogs();

    unawaited(refreshInBackground());
  }

  CatalogModel? getCatalog(String catalogId) => catalogs.value?.catalog(catalogId);

  OfferModel? findOffer(String offerId) {
    final all = catalogs.value?.catalogs.values ?? const <CatalogModel>[];
    for (final cat in all) {
      for (final off in cat.offers) {
        if (off.id == offerId) return off;
      }
    }
    return null;
  }

  Future<void> refreshInBackground() async {
    await Future.wait([
      _refreshTree(),
      _refreshCatalogs(),
    ]);
  }

  Future<void> _refreshTree() async {
    if (remoteUrl.isEmpty) return;
    final uri = Uri.tryParse(remoteUrl);
    if (uri == null || uri.scheme != 'https') return;
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return;
      final body = await utf8.decoder.bind(response).join();
      final fresh = _decodeAndValidateTree(body);
      final current = catalogue.value;
      if (current == null || fresh.version >= current.version) {
        catalogue.value = fresh;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, body);
      }
    } catch (_) {
      // Hors ligne ou indisponible : le cache affiché reste la référence.
    }
  }

  Future<void> _refreshCatalogs() async {
    if (remoteCatalogsUrl.isEmpty) return;
    final uri = Uri.tryParse(remoteCatalogsUrl);
    if (uri == null || uri.scheme != 'https') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final etag = prefs.getString('${_catalogsCacheKey}_etag');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (etag != null && etag.isNotEmpty) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final response = await request.close();
      if (response.statusCode == HttpStatus.notModified) return;
      if (response.statusCode != HttpStatus.ok) return;

      final newEtag = response.headers.value(HttpHeaders.etagHeader);
      final body = await utf8.decoder.bind(response).join();
      final fresh = _decodeAndValidateCatalogs(body);
      final current = catalogs.value;
      if (current == null || fresh.version >= current.version) {
        catalogs.value = fresh;
        await prefs.setString(_catalogsCacheKey, body);
        if (newEtag != null) {
          await prefs.setString('${_catalogsCacheKey}_etag', newEtag);
        }
      }
    } catch (_) {
      // Hors ligne : le cache affiché reste la référence.
    }
  }

  Future<UssdTree> _readBundledTree() async => _decodeAndValidateTree(
    await rootBundle.loadString('assets/data/ussd_tree.json'),
  );

  UssdTree _decodeAndValidateTree(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON USSD invalide.');
    }
    return UssdTree.fromJson(decoded);
  }

  Future<CatalogsData> _readBundledCatalogs() async => _decodeAndValidateCatalogs(
    await rootBundle.loadString('assets/data/catalogs.json'),
  );

  CatalogsData _decodeAndValidateCatalogs(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON Catalogue invalide.');
    }
    return CatalogsData.fromJson(decoded);
  }
}
