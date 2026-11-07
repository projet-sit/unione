class CatalogTab {
  final String id;
  final String label;

  const CatalogTab({required this.id, required this.label});

  factory CatalogTab.fromJson(Map<String, dynamic> json) {
    return CatalogTab(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label};
}

class CatalogLaunch {
  final String mode; // 'direct' or 'menu'
  final String code;

  const CatalogLaunch({required this.mode, required this.code});

  factory CatalogLaunch.fromJson(Map<String, dynamic> json) {
    return CatalogLaunch(
      mode: json['mode']?.toString() ?? 'direct',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'mode': mode, 'code': code};
}

class CatalogPaymentOption {
  final String id;
  final String label;
  final String code;

  const CatalogPaymentOption({
    required this.id,
    required this.label,
    required this.code,
  });

  factory CatalogPaymentOption.fromJson(Map<String, dynamic> json) {
    return CatalogPaymentOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'code': code};
}

class OfferModel {
  final String id;
  final String tab;
  final int price;
  final String title;
  final String? validityLabel;
  final List<String> contents;
  final List<String> badges;
  final String? hint;
  final String confidence; // 'official', 'third_party', 'to_test'
  final String? verifiedAt;
  final CatalogLaunch? launch;
  final List<CatalogPaymentOption>? payWith;

  const OfferModel({
    required this.id,
    required this.tab,
    required this.price,
    required this.title,
    this.validityLabel,
    this.contents = const [],
    this.badges = const [],
    this.hint,
    required this.confidence,
    this.verifiedAt,
    this.launch,
    this.payWith,
  });

  /// Calcule le volume approximatif en Mo pour évaluer le ratio volume/prix.
  double? get dataVolumeMb {
    final lower = title.toLowerCase();
    final matchGo = RegExp(r'([\d.,]+)\s*go').firstMatch(lower);
    if (matchGo != null) {
      final numStr = matchGo.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(numStr);
      if (val != null) return val * 1024.0;
    }
    final matchMo = RegExp(r'([\d.,]+)\s*mo').firstMatch(lower);
    if (matchMo != null) {
      final numStr = matchMo.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(numStr);
      if (val != null) return val;
    }
    return null;
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final rawContents = json['contents'];
    final List<String> parsedContents = [];
    if (rawContents is List) {
      parsedContents.addAll(rawContents.map((e) => e.toString()));
    } else if (rawContents is String && rawContents.isNotEmpty) {
      parsedContents.add(rawContents);
    }

    final rawBadges = json['badges'];
    final List<String> parsedBadges = [];
    if (rawBadges is List) {
      parsedBadges.addAll(rawBadges.map((e) => e.toString()));
    }

    final rawPayWith = json['payWith'];
    List<CatalogPaymentOption>? parsedPayWith;
    if (rawPayWith is List) {
      parsedPayWith = rawPayWith
          .whereType<Map<String, dynamic>>()
          .map(CatalogPaymentOption.fromJson)
          .toList(growable: false);
    }

    return OfferModel(
      id: json['id']?.toString() ?? '',
      tab: json['tab']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      validityLabel: json['validityLabel']?.toString(),
      contents: parsedContents,
      badges: parsedBadges,
      hint: json['hint']?.toString(),
      confidence: json['confidence']?.toString() ?? 'to_test',
      verifiedAt: json['verifiedAt']?.toString(),
      launch: json['launch'] is Map<String, dynamic>
          ? CatalogLaunch.fromJson(json['launch'] as Map<String, dynamic>)
          : null,
      payWith: parsedPayWith,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tab': tab,
    'price': price,
    'title': title,
    if (validityLabel != null) 'validityLabel': validityLabel,
    if (contents.isNotEmpty) 'contents': contents,
    if (badges.isNotEmpty) 'badges': badges,
    if (hint != null) 'hint': hint,
    'confidence': confidence,
    if (verifiedAt != null) 'verifiedAt': verifiedAt,
    if (launch != null) 'launch': launch!.toJson(),
    if (payWith != null) 'payWith': payWith!.map((p) => p.toJson()).toList(),
  };
}

class CatalogModel {
  final String id;
  final String operator;
  final String label;
  final List<CatalogTab> tabs;
  final CatalogLaunch launch;
  final List<CatalogPaymentOption> payWith;
  final String? source;
  final String? verifiedAt;
  final List<OfferModel> offers;

  const CatalogModel({
    required this.id,
    required this.operator,
    required this.label,
    required this.tabs,
    required this.launch,
    this.payWith = const [],
    this.source,
    this.verifiedAt,
    required this.offers,
  });

  /// Identifiant de l'offre au meilleur rapport volume/prix dans le catalogue.
  String? get bestValueOfferId {
    String? bestId;
    double maxRatio = 0.0;
    for (final offer in offers) {
      if (offer.price <= 0) continue;
      final volumeMb = offer.dataVolumeMb;
      if (volumeMb != null && volumeMb > 0) {
        final ratio = volumeMb / offer.price;
        if (ratio > maxRatio) {
          maxRatio = ratio;
          bestId = offer.id;
        }
      }
    }
    return bestId;
  }

  factory CatalogModel.fromJson(String id, Map<String, dynamic> json) {
    final rawTabs = json['tabs'];
    final tabs = (rawTabs is List ? rawTabs : const [])
        .whereType<Map<String, dynamic>>()
        .map(CatalogTab.fromJson)
        .toList(growable: false);

    final rawPayWith = json['payWith'];
    final payWith = (rawPayWith is List ? rawPayWith : const [])
        .whereType<Map<String, dynamic>>()
        .map(CatalogPaymentOption.fromJson)
        .toList(growable: false);

    final rawOffers = json['offers'];
    final offers = (rawOffers is List ? rawOffers : const [])
        .whereType<Map<String, dynamic>>()
        .map(OfferModel.fromJson)
        .toList(growable: false);

    return CatalogModel(
      id: id,
      operator: json['operator']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      tabs: tabs,
      launch: json['launch'] is Map<String, dynamic>
          ? CatalogLaunch.fromJson(json['launch'] as Map<String, dynamic>)
          : const CatalogLaunch(mode: 'direct', code: ''),
      payWith: payWith,
      source: json['source']?.toString(),
      verifiedAt: json['verifiedAt']?.toString(),
      offers: offers,
    );
  }

  Map<String, dynamic> toJson() => {
    'operator': operator,
    'label': label,
    'tabs': tabs.map((t) => t.toJson()).toList(),
    'launch': launch.toJson(),
    if (payWith.isNotEmpty) 'payWith': payWith.map((p) => p.toJson()).toList(),
    if (source != null) 'source': source,
    if (verifiedAt != null) 'verifiedAt': verifiedAt,
    'offers': offers.map((o) => o.toJson()).toList(),
  };
}

class CatalogsData {
  final int version;
  final Map<String, CatalogModel> catalogs;

  const CatalogsData({required this.version, required this.catalogs});

  CatalogModel? catalog(String id) => catalogs[id];

  factory CatalogsData.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final rawCatalogs = json['catalogs'];
    final Map<String, CatalogModel> parsed = {};
    if (rawCatalogs is Map<String, dynamic>) {
      for (final entry in rawCatalogs.entries) {
        if (entry.value is Map<String, dynamic>) {
          parsed[entry.key] = CatalogModel.fromJson(
            entry.key,
            entry.value as Map<String, dynamic>,
          );
        }
      }
    }
    return CatalogsData(version: version, catalogs: parsed);
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'catalogs': catalogs.map((k, v) => MapEntry(k, v.toJson())),
  };
}
