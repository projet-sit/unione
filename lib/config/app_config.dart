/// Configuration unique des canaux de contact et de partage.
///
/// Le numéro WhatsApp et les messages préremplis sont centralisés ici afin
/// qu'ils restent identiques dans tous les écrans de l'application.
class AppConfig {
  const AppConfig._();

  /// Numéro WhatsApp de l'assistance, au format international sans « + »,
  /// sans espaces ni tirets (format attendu par `wa.me`).
  static const String whatsappNumber = '22991831317';

  /// Même numéro, dans un format lisible pour l'utilisateur.
  static const String whatsappDisplay = '+229 91 83 13 17';

  /// Version affichée dans les messages d'assistance.
  static const String appVersion = '1.0.0+2';

  /// Identifiant de publication Android (utilisé par le Play Store).
  static const String packageId = 'com.zoli.app';

  /// Fiche Play Store de l'application.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageId';

  /// Lien public de partage.
  ///
  /// Pointe par défaut vers la fiche Play Store. Il peut être remplacé au
  /// build pour utiliser un site dédié :
  /// `flutter build apk --dart-define=UNIONE_SHARE_URL=https://...`.
  static const String shareUrl = String.fromEnvironment(
    'UNIONE_SHARE_URL',
    defaultValue: 'https://play.google.com/store/apps/details?id=com.zoli.app',
  );

  static bool get hasShareUrl =>
      shareUrl.startsWith('https://') || shareUrl.startsWith('http://');

  /// Lien `wa.me` avec message encodé, ouvrable par WhatsApp ou un navigateur.
  static Uri whatsappUri({String? message}) {
    final base = 'https://wa.me/$whatsappNumber';
    if (message == null || message.isEmpty) return Uri.parse(base);
    return Uri.parse('$base?text=${Uri.encodeComponent(message)}');
  }

  /// Lien direct vers l'application WhatsApp installée.
  static Uri whatsappAppUri({String? message}) {
    final base = 'whatsapp://send?phone=$whatsappNumber';
    if (message == null || message.isEmpty) return Uri.parse(base);
    return Uri.parse('$base&text=${Uri.encodeComponent(message)}');
  }

  /// Texte proposé dans la feuille de partage native.
  static String get shareText {
    const intro =
        'Découvrez UNIONE, l’application qui simplifie l’accès aux codes '
        'USSD de MTN, Moov et Celtiis au Bénin.';
    return hasShareUrl ? '$intro\n$shareUrl' : intro;
  }

  /// Message WhatsApp prérempli pour signaler un problème général.
  static String reportProblemMessage({String? androidVersion, String? model}) {
    return [
      'Bonjour, je souhaite signaler un problème avec UNIONE.',
      '',
      'Version de l’app : $appVersion',
      if (androidVersion != null && androidVersion.isNotEmpty)
        'Android : $androidVersion',
      if (model != null && model.isNotEmpty) 'Modèle : $model',
      '',
      'Description du problème : ',
    ].join('\n');
  }

  /// Message WhatsApp prérempli pour signaler un tarif incorrect.
  static String reportCatalogMessage({
    required String operatorName,
    required String catalogLabel,
    String? verifiedAt,
  }) {
    return 'Bonjour, je souhaite signaler un tarif incorrect ou obsolète '
        'sur UNIONE.\n\n'
        'Opérateur : $operatorName\n'
        'Catalogue : $catalogLabel\n'
        'Dernière mise à jour affichée : ${verifiedAt ?? 'inconnue'}\n'
        'Version de l’app : $appVersion';
  }

  /// Message WhatsApp prérempli pour signaler un code USSD inopérant.
  static String reportCodeMessage({
    required String operatorName,
    required String path,
    required String service,
    String? code,
    String? treeVersion,
  }) {
    return 'Bonjour, je souhaite signaler un code qui ne marche plus.\n\n'
        'Opérateur : $operatorName\n'
        'Chemin : $path\n'
        'Service : $service\n'
        'Code : ${code ?? 'non disponible'}\n'
        'Version de l’app : $appVersion'
        '${treeVersion == null ? '' : '\nVersion du JSON : $treeVersion'}';
  }
}
