import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/backend_config.dart';
import '../models/catalog_model.dart';
import '../models/menu_node.dart';

/// Réponse d'un appel distant (succès, 304 ou autre code).
class RemoteResponse {
  final int statusCode;
  final String? etag;
  final String body;

  const RemoteResponse({required this.statusCode, this.etag, this.body = ''});
}

/// Fournit le catalogue embarqué, son cache local et, si configurée, la source HTTPS.
class CodesRepository {
  CodesRepository._();
  static final CodesRepository instance = CodesRepository._();

  static const _cacheKey = 'ussd_tree_v5';
  static const _treeEtagKey = 'ussd_tree_v5_etag';
  static const _catalogsCacheKey = 'catalogs_v1';
  static const _catalogsEtagKey = 'catalogs_v1_etag';

  /// Permet aux tests d'injecter un faux transport HTTP (voir
  /// `test/codes_repository_remote_test.dart`). Toujours `null` en production.
  @visibleForTesting
  static Future<RemoteResponse> Function(Uri uri, String? etag)?
  debugFetchOverride;

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

  CatalogModel? getCatalog(String catalogId) =>
      catalogs.value?.catalog(catalogId);

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
    await Future.wait([_refreshTree(), _refreshCatalogs()]);
  }

  Future<void> _refreshTree() async {
    final uri = BackendConfig.parseUrl(BackendConfig.codesUrl);
    if (uri == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final etag = prefs.getString(_treeEtagKey);
      final response = await _fetch(uri, etag);
      if (response.statusCode == HttpStatus.notModified) return;
      if (response.statusCode != HttpStatus.ok) return;

      final fresh = _decodeAndValidateTree(response.body);
      final current = catalogue.value;
      // On n'applique que les versions strictement plus récentes.
      if (current == null || fresh.version > current.version) {
        catalogue.value = fresh;
        await prefs.setString(_cacheKey, response.body);
        if (response.etag != null) {
          await prefs.setString(_treeEtagKey, response.etag!);
        }
      }
    } catch (_) {
      // Hors ligne ou indisponible : le cache affiché reste la référence.
    }
  }

  Future<void> _refreshCatalogs() async {
    final uri = BackendConfig.parseUrl(BackendConfig.catalogsUrl);
    if (uri == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final etag = prefs.getString(_catalogsEtagKey);
      final response = await _fetch(uri, etag);
      if (response.statusCode == HttpStatus.notModified) return;
      if (response.statusCode != HttpStatus.ok) return;

      final fresh = _decodeAndValidateCatalogs(response.body);
      final current = catalogs.value;
      // On n'applique que les versions strictement plus récentes.
      if (current == null || fresh.version > current.version) {
        catalogs.value = fresh;
        await prefs.setString(_catalogsCacheKey, response.body);
        if (response.etag != null) {
          await prefs.setString(_catalogsEtagKey, response.etag!);
        }
      }
    } catch (_) {
      // Hors ligne : le cache affiché reste la référence.
    }
  }

  Future<RemoteResponse> _fetch(Uri uri, String? etag) {
    final override = debugFetchOverride;
    if (override != null) return override(uri, etag);
    return _defaultFetch(uri, etag);
  }

  Future<RemoteResponse> _defaultFetch(Uri uri, String? etag) async {
    final client = HttpClient()..connectionTimeout = BackendConfig.timeout;
    try {
      final request = await client.getUrl(uri).timeout(BackendConfig.timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (etag != null && etag.isNotEmpty) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final response = await request.close().timeout(BackendConfig.timeout);
      final newEtag = response.headers.value(HttpHeaders.etagHeader);
      if (response.statusCode == HttpStatus.notModified) {
        return RemoteResponse(statusCode: response.statusCode, etag: newEtag);
      }
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(BackendConfig.timeout);
      return RemoteResponse(
        statusCode: response.statusCode,
        etag: newEtag,
        body: body,
      );
    } finally {
      client.close();
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
    // UssdTree valide le schéma, l'unicité des ids et l'absence de cycle.
    return UssdTree.fromJson(decoded);
  }

  Future<CatalogsData> _readBundledCatalogs() async =>
      _decodeAndValidateCatalogs(
        await rootBundle.loadString('assets/data/catalogs.json'),
      );

  CatalogsData _decodeAndValidateCatalogs(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON Catalogue invalide.');
    }
    final parsed = CatalogsData.fromJson(decoded);
    _validateCatalogIds(parsed);
    return parsed;
  }

  /// Unicité des ids : catalogue, onglets et offres. Tout duplicata ou id
  /// vide rend le document distant invalide et le cache est conservé.
  void _validateCatalogIds(CatalogsData data) {
    final catalogIds = <String>{};
    for (final entry in data.catalogs.entries) {
      if (entry.key.isEmpty || !catalogIds.add(entry.key)) {
        throw const FormatException('ID catalogue dupliqué ou vide.');
      }
      final tabIds = <String>{};
      for (final tab in entry.value.tabs) {
        if (tab.id.isEmpty || !tabIds.add(tab.id)) {
          throw const FormatException('ID onglet dupliqué ou vide.');
        }
      }
      final offerIds = <String>{};
      for (final offer in entry.value.offers) {
        if (offer.id.isEmpty || !offerIds.add(offer.id)) {
          throw const FormatException('ID offre dupliqué ou vide.');
        }
      }
    }
  }
}
