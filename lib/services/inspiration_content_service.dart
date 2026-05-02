import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/models/inspiration_catalog.dart';
import '../core/models/inspiration_item.dart';

class InspirationContentService {
  static const assetPath = 'assets/content/inspiration.json';

  Future<InspirationCatalog> loadCatalog() async {
    final rawContent = await rootBundle.loadString(assetPath);
    final json = jsonDecode(rawContent) as Map<String, dynamic>;

    return InspirationCatalog(
      quotes: _parseItems(json['quotes'], type: InspirationType.quote),
      affirmations: _parseItems(
        json['affirmations'],
        type: InspirationType.affirmation,
      ),
      scriptures: _parseItems(
        json['scriptures'],
        type: InspirationType.scripture,
      ),
    );
  }

  List<InspirationItem> _parseItems(
    Object? rawItems, {
    required InspirationType type,
  }) {
    final items = rawItems as List<dynamic>? ?? const [];

    return items.map((rawItem) {
      return InspirationItem.fromJson(
        rawItem as Map<String, dynamic>,
        type: type,
      );
    }).toList(growable: false);
  }
}
