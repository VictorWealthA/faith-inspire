enum InspirationType { quote, affirmation, scripture }

class InspirationItem {
  final String id;
  final InspirationType type;
  final String text;
  final String? author;
  final String? reference;
  final String background;
  final List<String> tags;
  final bool isFavorite;

  const InspirationItem({
    required this.id,
    required this.type,
    required this.text,
    this.author,
    this.reference,
    required this.background,
    this.tags = const [],
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
        tags: tags,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  factory InspirationItem.fromJson(
    Map<String, dynamic> json, {
    required InspirationType type,
  }) {
    return InspirationItem(
      id: json['id'] as String,
      type: type,
      text: json['text'] as String,
      author: json['author'] as String?,
      reference: json['reference'] as String?,
      background: json['background'] as String,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag as String)
          .toList(growable: false),
    );
  }
}
