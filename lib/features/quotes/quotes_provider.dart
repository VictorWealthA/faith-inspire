import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/inspiration_item.dart';

final quotesProvider = StateNotifierProvider<QuotesNotifier, List<InspirationItem>>((ref) {
  return QuotesNotifier();
});

class QuotesNotifier extends StateNotifier<List<InspirationItem>> {
  QuotesNotifier() : super(_initialQuotes);

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

final _initialQuotes = [
  InspirationItem(
    id: '1',
    type: InspirationType.quote,
    text: 'You are a success going somewhere to happen.',
    author: 'Pastor Chris Oyakhilome',
    background: '#F5F7FA',
  ),
  InspirationItem(
    id: '2',
    type: InspirationType.quote,
    text: 'The Word of God is your sure foundation.',
    author: 'Pastor Chris Oyakhilome',
    background: '#E0EAFC',
  ),
  InspirationItem(
    id: '3',
    type: InspirationType.quote,
    text: 'You are the light of the world.',
    author: 'Pastor Chris Oyakhilome',
    background: '#FCEABB',
  ),
];
