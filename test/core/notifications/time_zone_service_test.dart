import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('applies the device zone and reports changes', () async {
    var zone = 'Asia/Kolkata';
    final s = TimeZoneService(deviceZone: () async => zone);
    await s.init();
    expect(tz.local.name, 'Asia/Kolkata');

    expect(await s.refresh(), isFalse);

    zone = 'America/New_York';
    expect(await s.refresh(), isTrue);
    expect(tz.local.name, 'America/New_York');
  });

  test(
    'unknown zone falls back to UTC on first run, keeps zone later',
    () async {
      var zone = 'Not/AZone';
      final s = TimeZoneService(deviceZone: () async => zone);
      await s.init();
      expect(tz.local.name, 'UTC');

      zone = 'Asia/Tokyo';
      await s.refresh();
      zone = 'Bad/Alias';
      expect(await s.refresh(), isFalse);
      expect(tz.local.name, 'Asia/Tokyo');
    },
  );

  test('platform errors fall back to UTC', () async {
    final s = TimeZoneService(
      deviceZone: () async => throw PlatformException(code: 'x'),
    );
    await s.init();
    expect(tz.local.name, 'UTC');
  });
}
