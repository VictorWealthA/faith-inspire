import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/favorites_service.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

final initialFavoriteIdsProvider = Provider<Set<String>>((ref) {
  return const <String>{};
});

final favoriteIdsProvider =
    StateNotifierProvider<FavoriteIdsNotifier, Set<String>>((ref) {
      return FavoriteIdsNotifier(
        service: ref.watch(favoritesServiceProvider),
        initialIds: ref.watch(initialFavoriteIdsProvider),
      );
    });

class FavoriteIdsNotifier extends StateNotifier<Set<String>> {
  FavoriteIdsNotifier({
    required FavoritesService service,
    required Set<String> initialIds,
  })  : _service = service,
        super({...initialIds});

  final FavoritesService _service;

  Future<void> toggleFavorite(String id) async {
    final next = {...state};

    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }

    state = next;
    await _service.saveFavorites(next.toList()..sort());
  }
}
