enum InspirationType { quote, affirmation, scripture }

class InspirationItem {
  final String id;
  final InspirationType type;
  final String text;
  final String? author;
  final String? reference;
  final String background;
  final bool isFavorite;

  InspirationItem({
    required this.id,
    required this.type,
    required this.text,
    this.author,
    this.reference,
    required this.background,
    this.isFavorite = false,
  });

  InspirationItem copyWith({
    bool? isFavorite,
  }) => InspirationItem(
        id: id,
        type: type,
        text: text,
        author: author,
        reference: reference,
        background: background,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
