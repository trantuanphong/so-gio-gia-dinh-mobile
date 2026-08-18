import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/app_models.dart';
import '../utils/lunar_utils.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleAllReminders(AppState state) async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
    int idCounter = 1;

    for (final mem in state.memorials) {
      final nextOccur = LunarUtils.getNextOccurrence(mem.lunarMonth, mem.lunarDay, false);
      if (nextOccur == null) continue;

      final reminders = state.reminders.where((r) => r.memorialId == mem.id && r.enabled);
      for (final rem in reminders) {
        final notifyDate = nextOccur.subtract(Duration(days: rem.daysBefore));
        final notifyTime = DateTime(notifyDate.year, notifyDate.month, notifyDate.day, 8, 0); // 8:00 AM

        if (notifyTime.isAfter(DateTime.now())) {
          final tzTime = tz.TZDateTime.from(notifyTime, tz.local);
          final title = "Nhắc nhở ngày giỗ: ${mem.name}";
          final body = rem.daysBefore == 0
              ? "Hôm nay là ngày giỗ ${mem.name}"
              : "Còn ${rem.daysBefore} ngày nữa đến ngày giỗ ${mem.name}";

          await _notifications.zonedSchedule(
            idCounter++,
            title,
            body,
            tzTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'memorial_reminders',
                'Nhắc nhở ngày giỗ',
                channelDescription: 'Thông báo nhắc nhở ngày giỗ gia đình',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
  }
}
