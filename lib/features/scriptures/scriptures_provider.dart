import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/inspiration_item.dart';

final scripturesProvider = StateNotifierProvider<ScripturesNotifier, List<InspirationItem>>((ref) {
  return ScripturesNotifier();
});

class ScripturesNotifier extends StateNotifier<List<InspirationItem>> {
  ScripturesNotifier() : super(_initialScriptures);

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

final _initialScriptures = [
  InspirationItem(
    id: 's1',
    type: InspirationType.scripture,
    text: 'I can do all things through Christ who strengthens me.',
    reference: 'Philippians 4:13',
    background: '#F5F7FA',
  ),
  InspirationItem(
    id: 's2',
    type: InspirationType.scripture,
    text: 'The Lord is my shepherd; I shall not want.',
    reference: 'Psalm 23:1',
    background: '#E0EAFC',
  ),
  InspirationItem(
    id: 's3',
    type: InspirationType.scripture,
    text: 'For God so loved the world that He gave His only begotten Son.',
    reference: 'John 3:16',
    background: '#FCEABB',
  ),
];
