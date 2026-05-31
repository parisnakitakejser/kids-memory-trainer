import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/services/update_service.dart';

void main() {
  test('detects newer stable releases', () {
    expect(UpdateService.isNewerVersion('1.2.0', '1.1.9'), isTrue);
    expect(UpdateService.isNewerVersion('1.2.0', '1.2.0'), isFalse);
    expect(UpdateService.isNewerVersion('1.1.9', '1.2.0'), isFalse);
  });

  test('detects newer rc releases', () {
    expect(UpdateService.isNewerVersion('1.2.0-rc.1', '1.1.9'), isTrue);
    expect(UpdateService.isNewerVersion('1.2.0-rc.2', '1.2.0-rc.1'), isTrue);
    expect(UpdateService.isNewerVersion('1.2.0', '1.2.0-rc.2'), isTrue);
    expect(UpdateService.isNewerVersion('1.2.0-rc.1', '1.2.0'), isFalse);
  });
}
