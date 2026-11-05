import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Keeps `tz.local` in step with the device zone so wall-clock schedules
/// (8:00 medicine) follow the user when they travel.
class TimeZoneService {
  TimeZoneService({
    this._deviceZone = _platformZone,
    this._clock = DateTime.now,
  });

  final Future<String> Function() _deviceZone;
  final DateTime Function() _clock;
  String? _current;

  tz.Location get location => tz.local;

  tz.TZDateTime now() => tz.TZDateTime.from(_clock(), tz.local);

  static bool _dataLoaded = false;

  /// Loads the tz database and applies the device zone.
  Future<void> init() async {
    if (!_dataLoaded) {
      tzdata.initializeTimeZones();
      _dataLoaded = true;
    }
    await refresh();
  }

  /// Re-reads the device zone. Returns true if it changed.
  Future<bool> refresh() async {
    String id;
    try {
      id = await _deviceZone();
    } on PlatformException {
      id = 'UTC';
    }
    if (id == _current) return false;
    try {
      tz.setLocalLocation(tz.getLocation(id));
    } on tz.LocationNotFoundException {
      // Unknown alias: keep the previous zone, or UTC on first run.
      if (_current != null) return false;
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    final changed = _current != null;
    _current = id;
    return changed;
  }

  static Future<String> _platformZone() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;
}
