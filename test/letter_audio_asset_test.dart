import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads nested letter audio assets from the Flutter bundle', () async {
    final data = await rootBundle.load(
      'assets/sounds/letters/da/o-lower-letter.aiff',
    );

    expect(data.lengthInBytes, greaterThan(0));
  });
}
