import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/services/theme_asset_service.dart';

void main() {
  group('ThemeAssetService.naturalSort', () {
    test('sorts pure numeric filenames numerically', () {
      expect(ThemeAssetService.naturalSort('1.png', '2.png'), isNegative);
      expect(ThemeAssetService.naturalSort('2.png', '1.png'), isPositive);
    });

    test(
        'sorts numeric filenames with different digit lengths correctly (natural sort)',
        () {
      // 2 should come before 10 in natural sort
      expect(ThemeAssetService.naturalSort('2.png', '10.png'), isNegative);
      expect(ThemeAssetService.naturalSort('10.png', '2.png'), isPositive);
    });

    test('sorts standard alphabetical filenames alphabetically', () {
      expect(ThemeAssetService.naturalSort('a.png', 'b.png'), isNegative);
      expect(ThemeAssetService.naturalSort('b.png', 'a.png'), isPositive);
    });

    test('sorts numbered vs non-numbered filenames with numbers first', () {
      expect(ThemeAssetService.naturalSort('10.png', 'a.png'), isNegative);
      expect(ThemeAssetService.naturalSort('a.png', '10.png'), isPositive);
    });

    test(
        'sorts mixed filenames with same leading number by alphabetical suffix',
        () {
      expect(ThemeAssetService.naturalSort('2_apple.png', '2_banana.png'),
          isNegative);
      expect(ThemeAssetService.naturalSort('2_banana.png', '2_apple.png'),
          isPositive);
    });

    test('sorts a complete list of mixed assets in a correct natural order',
        () {
      final input = [
        'build_assets/animals/10.png',
        'build_assets/animals/a.png',
        'build_assets/animals/2.png',
        'build_assets/animals/1.png',
        'build_assets/animals/b.png',
      ];

      final expected = [
        'build_assets/animals/1.png',
        'build_assets/animals/2.png',
        'build_assets/animals/10.png',
        'build_assets/animals/a.png',
        'build_assets/animals/b.png',
      ];

      final sorted = List<String>.from(input)
        ..sort(ThemeAssetService.naturalSort);
      expect(sorted, expected);
    });
  });
}
