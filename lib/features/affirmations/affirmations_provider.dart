import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inspiration_item.dart';
import '../content/inspiration_catalog_provider.dart';
import '../favorites/favorite_ids_provider.dart';

final affirmationsProvider = Provider<List<InspirationItem>>((ref) {
  final catalog = ref.watch(inspirationCatalogProvider);
  final favoriteIds = ref.watch(favoriteIdsProvider);

  return catalog.affirmations.map((item) {
    return item.copyWith(isFavorite: favoriteIds.contains(item.id));
  }).toList(growable: false);
});
