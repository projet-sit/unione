/// Référence centralisée des assets graphiques (aucun chemin en dur ailleurs).
class AppAssets {
  const AppAssets._();

  /// Nouveau logo officiel (fichier source déposé à la racine du projet,
  /// copié dans `assets/images/`).
  static const String appLogo = 'assets/images/app_logo.png';

  /// Icône historique, repli si le nouveau logo est indisponible.
  static const String legacyIcon = 'assets/icon.png';

  /// Logos des opérateurs (sources officielles).
  static const String operatorsDir = 'assets/logos/';

  /// Données embarquées (JSON versionnés).
  static const String dataDir = 'assets/data/';

  /// Traductions.
  static const String translationsDir = 'assets/translations/';
}
