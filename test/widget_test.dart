import 'package:flutter_test/flutter_test.dart';

import 'package:shelfcontrol/main.dart';

void main() {
  testWidgets('app renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ShelfControlApp());
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsWidgets);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
  });
}
