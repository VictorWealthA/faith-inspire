import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inspiration_item.dart';
import '../affirmations/affirmations_provider.dart';
import '../quotes/quotes_provider.dart';
import '../scriptures/scriptures_provider.dart';

final favoritesProvider = Provider<List<InspirationItem>>((ref) {
  final quotes = ref.watch(quotesProvider);
  final affirmations = ref.watch(affirmationsProvider);
  final scriptures = ref.watch(scripturesProvider);

  return [
    ...quotes,
    ...affirmations,
    ...scriptures,
  ].where((item) => item.isFavorite).toList(growable: false);
});
