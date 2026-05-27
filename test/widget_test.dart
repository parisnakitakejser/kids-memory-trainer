import 'package:flutter_test/flutter_test.dart';

import 'package:memory_game/main.dart';

void main() {
  testWidgets('shows the memory game main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryGameApp());

    expect(find.text('Kids Memory Game'), findsOneWidget);
    expect(find.text('Select Theme'), findsOneWidget);
    expect(find.text('Single Player (Time Trial)'), findsOneWidget);
  });
}
