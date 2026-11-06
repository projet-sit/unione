import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  UserPreferencesService._();
  static final instance = UserPreferencesService._();

  static const _favoritesKey = 'favorite_ussd_service_ids';

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

  Future<void> saveLastSim(String operatorId, int subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sim_$operatorId', subscriptionId);
  }

  Future<int?> lastSim(String operatorId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_sim_$operatorId');
  }

  Future<void> clearLastSim(String operatorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sim_$operatorId');
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
}
