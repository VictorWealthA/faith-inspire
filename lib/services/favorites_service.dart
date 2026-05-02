import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const storageKey = 'favorite_ids';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(storageKey) ?? [];
  }

  Future<void> saveFavorites(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, ids);
  }
}
