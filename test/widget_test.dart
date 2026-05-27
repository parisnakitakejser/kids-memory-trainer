import 'package:flutter_test/flutter_test.dart';

import 'package:memory_game/main.dart';

void main() {
  testWidgets('shows the memory game main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryGameApp(enableUpdateCheck: false));

    expect(find.text('Kids Memory Game'), findsOneWidget);
    expect(find.text('Player Mode'), findsOneWidget);
    expect(find.text('Card Mode'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Start Single Player'), findsOneWidget);
  });
}
