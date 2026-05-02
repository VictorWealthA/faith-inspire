import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:faith_inspire/core/models/inspiration_catalog.dart';
import 'package:faith_inspire/core/models/inspiration_item.dart';
import 'package:faith_inspire/features/content/inspiration_catalog_provider.dart';
import 'package:faith_inspire/features/favorites/favorite_ids_provider.dart';
import 'package:faith_inspire/main.dart';

void main() {
  const catalog = InspirationCatalog(
    quotes: [
      InspirationItem(
        id: '1',
        type: InspirationType.quote,
        text: 'You are a success going somewhere to happen.',
        author: 'Pastor Chris Oyakhilome',
        background: '#F5F7FA',
        tags: ['purpose', 'confidence'],
      ),
    ],
    affirmations: [
      InspirationItem(
        id: 'a1',
        type: InspirationType.affirmation,
        text: 'I am blessed and highly favored.',
        background: '#E0EAFC',
        tags: ['favor', 'gratitude'],
      ),
    ],
    scriptures: [
      InspirationItem(
        id: 's1',
        type: InspirationType.scripture,
        text: 'I can do all things through Christ who strengthens me.',
        reference: 'Philippians 4:13',
        background: '#FCEABB',
        tags: ['strength', 'confidence'],
      ),
    ],
  );

  Widget buildTestApp({Set<String> initialFavoriteIds = const <String>{}}) {
    return TickerMode(
      enabled: false,
      child: ProviderScope(
        overrides: [
          inspirationCatalogProvider.overrideWithValue(catalog),
          initialFavoriteIdsProvider.overrideWithValue(initialFavoriteIds),
        ],
        child: const FaithInspireApp(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads and shows Quotes screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    // Verify title is present in the initial screen.
    expect(find.text('Quotes'), findsWidgets);

    // Verify at least one quote is displayed
    expect(find.textContaining('success'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    // Tap Affirmations tab
    await tester.tap(find.text('Affirmations'));
    await tester.pumpAndSettle();

    expect(find.text('Affirmations'), findsWidgets);

    // Tap Scriptures tab
    await tester.tap(find.text('Scriptures'));
    await tester.pumpAndSettle();

    expect(find.text('Scriptures'), findsWidgets);

    // Tap Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('No favorites saved yet.'), findsOneWidget);
  });

  testWidgets('Favorited items appear in the Favorites screen', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.textContaining('success'), findsOneWidget);
  });

  testWidgets('Saved favorites load on app start', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(initialFavoriteIds: {'s1'}));

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.textContaining('strengthens me'), findsOneWidget);
  });

  testWidgets('Action buttons are tappable', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byTooltip('Favorite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.textContaining('success'), findsOneWidget);

    await tester.tap(find.text('Quotes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Pause Slideshow'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Start Slideshow'), findsOneWidget);
  });
}
