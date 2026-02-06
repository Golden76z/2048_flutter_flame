import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_2048_flame/main.dart';

void main() {
  testWidgets('App shows 2048 title', (WidgetTester tester) async {
    await tester.pumpWidget(const Flutter2048App());
    expect(find.text('2048'), findsOneWidget);
  });
}
