import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inspiration_item.dart';

final affirmationsProvider =
    StateNotifierProvider<AffirmationsNotifier, List<InspirationItem>>((ref) {
  return AffirmationsNotifier();
});

class AffirmationsNotifier extends StateNotifier<List<InspirationItem>> {
  AffirmationsNotifier() : super(_initialAffirmations);

  void toggleFavorite(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(isFavorite: !item.isFavorite)
        else
          item,
    ];
  }
}

List<InspirationItem> _initialAffirmations = [
  InspirationItem(
    id: 'a1',
    type: InspirationType.affirmation,
    text: 'I am blessed and highly favored.',
    background: '#F5F7FA',
  ),
  InspirationItem(
    id: 'a2',
    type: InspirationType.affirmation,
    text: 'I walk in divine health and prosperity.',
    background: '#E0EAFC',
  ),
  InspirationItem(
    id: 'a3',
    type: InspirationType.affirmation,
    text: 'I am a light to my world.',
    background: '#FCEABB',
  ),
];
