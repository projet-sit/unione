import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  UserPreferencesService._();
  static final instance = UserPreferencesService._();

  static const _favoritesKey = 'favorite_ussd_service_ids';
  static const _recentsKey = 'recent_ussd_entries';
  static const _onboardingKey = 'onboarding_seen';
  static const _phonePrimingKey = 'phone_permission_priming_seen';

  Future<Set<String>> favorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const <String>[]).toSet();
  }

  Future<bool> toggleFavorite(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await favorites();
    final isNowFavorite = !ids.contains(serviceId);
    if (isNowFavorite) {
      ids.add(serviceId);
    } else {
      ids.remove(serviceId);
    }
    await prefs.setStringList(_favoritesKey, ids.toList()..sort());
    return isNowFavorite;
  }

  /// Option de paiement mémorisée pour un catalogue (ex. Crédit / MoMo).
  Future<String?> catalogPayment(String catalogId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('catalog_payment_$catalogId');
  }

  Future<void> saveCatalogPayment(String catalogId, String optionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('catalog_payment_$catalogId', optionId);
  }

  /// Derniers services réellement lancés, du plus récent au plus ancien.
  ///
  /// Les entrées sont légères et ne contiennent aucune donnée personnelle :
  /// `n:<id>` pour un service et `o:<catalogue>:<offre>` pour un forfait.
  Future<List<String>> recents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentsKey) ?? const <String>[];
  }

  Future<void> addRecent(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await recents();
    final updated = [
      entry,
      ...current.where((item) => item != entry),
    ].take(6).toList(growable: false);
    await prefs.setStringList(_recentsKey, updated);
  }

  Future<void> clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentsKey);
  }

  Future<bool> onboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> phonePrimingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_phonePrimingKey) ?? false;
  }

  Future<void> setPhonePrimingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_phonePrimingKey, true);
  }
}
