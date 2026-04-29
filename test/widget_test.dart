import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:faith_inspire/main.dart';

void main() {
  testWidgets('App loads and shows Quotes screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FaithInspireApp(),
      ),
    );

    // Verify title is present in the initial screen.
    expect(find.text('Quotes'), findsWidgets);

    // Verify at least one quote is displayed
    expect(find.textContaining('success'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FaithInspireApp(),
      ),
    );

    // Tap Affirmations tab
    await tester.tap(find.text('Affirmations'));
    await tester.pumpAndSettle();

    expect(find.text('Affirmations'), findsWidgets);

    // Tap Scriptures tab
    await tester.tap(find.text('Scriptures'));
    await tester.pumpAndSettle();

    expect(find.text('Scriptures'), findsWidgets);
  });
}
