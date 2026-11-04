import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/notifications.dart';

void main() {
  test('notification ids are stable and fit Android int ids', () {
    const first = '0b6b0d1e-6f8d-4c5f-9a4d-1f9f6f2a6b7c';
    const second = '7a1c7e2f-1b3d-4d2c-8e5a-9c3b1a2d4e5f';

    expect(notificationIdFor(first), notificationIdFor(first));
    expect(notificationIdFor(first), isNot(notificationIdFor(second)));
    expect(notificationIdFor(first), greaterThanOrEqualTo(0));
    expect(notificationIdFor(first), lessThan(1 << 31));
  });
}
