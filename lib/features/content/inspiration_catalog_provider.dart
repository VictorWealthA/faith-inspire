import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inspiration_catalog.dart';

final inspirationCatalogProvider = Provider<InspirationCatalog>((ref) {
  return const InspirationCatalog();
});
