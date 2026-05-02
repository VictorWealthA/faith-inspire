import 'inspiration_item.dart';

class InspirationCatalog {
  const InspirationCatalog({
    this.quotes = const [],
    this.affirmations = const [],
    this.scriptures = const [],
  });

  final List<InspirationItem> quotes;
  final List<InspirationItem> affirmations;
  final List<InspirationItem> scriptures;

  List<InspirationItem> get allItems => [
        ...quotes,
        ...affirmations,
        ...scriptures,
      ];
}
