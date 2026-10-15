
import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class PrayerNotificationService {
  PrayerNotificationService._();

  static final PrayerNotificationService instance =
  PrayerNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const MethodChannel _adhanChannel =
  MethodChannel('com.example.quran/adhan');

  static const String _channelId = 'prayer_times_channel';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
    );

    await _plugin.initialize(
      settings: initializationSettings,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
  }) async {
    await initialize();

    // Remove the previous Flutter notifications.
    await _plugin.cancelAll();

    final coordinates = Coordinates(latitude, longitude);
    final parameters = CalculationMethod.egyptian.getParameters();
    parameters.madhab = Madhab.shafi;

    final now = tz.TZDateTime.now(tz.local);
    var notificationId = 1000;

    // Schedule Flutter notifications for the next seven days.
    for (var day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));

      final prayerTimes = PrayerTimes(
        coordinates,
        DateComponents(date.year, date.month, date.day),
        parameters,
      );

      final prayers = <MapEntry<String, DateTime>>[
        MapEntry('الفجر', prayerTimes.fajr),
        MapEntry('الظهر', prayerTimes.dhuhr),
        MapEntry('العصر', prayerTimes.asr),
        MapEntry('المغرب', prayerTimes.maghrib),
        MapEntry('العشاء', prayerTimes.isha),
      ];

      for (final prayer in prayers) {
        final time = prayer.value;

        final scheduledDate = tz.TZDateTime(
          tz.local,
          time.year,
          time.month,
          time.day,
          time.hour,
          time.minute,
          time.second,
        );

        if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
          continue;
        }

        await _plugin.zonedSchedule(
          id: notificationId++,
          title: 'حان وقت صلاة ${prayer.key}',
          body: 'حان الآن وقت الصلاة',
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              'مواقيت الصلاة',
              channelDescription: 'تنبيهات مواقيت الصلوات الخمس',
              importance: Importance.max,
              priority: Priority.high,
              playSound: false,
              enableVibration: true,
            ),
          ),
          androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    // Android calculates and schedules the native adhan alarms.
    // Send the selected city's coordinates only once.
    await _adhanChannel.invokeMethod<int>(
      'scheduleAdhan',
      <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<void> cancelPrayerNotifications() async {
    await initialize();

    await _plugin.cancelAll();
    await _adhanChannel.invokeMethod<void>('cancelAdhan');
  }

  Future<bool> areNotificationsEnabled() async {
    await initialize();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }
}
