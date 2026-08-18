import 'vietnamese_lunar.dart';

class SolarDate {
  final int year;
  final int month;
  final int day;

  SolarDate({required this.year, required this.month, required this.day});

  DateTime toDateTime() => DateTime(year, month, day);
}

class LunarDate {
  final int day;
  final int month;
  final int year;
  final bool isLeap;

  LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeap,
  });
}

class LunarUtils {
  static SolarDate lunarToSolar(int lunarYear, int lunarMonth, int lunarDay, {bool isLeap = false}) {
    final res = VietnameseLunar.convertLunarToSolar(lunarDay, lunarMonth, lunarYear, isLeap);
    return SolarDate(year: res[2], month: res[1], day: res[0]);
  }

  static LunarDate solarToLunar(int year, int month, int day) {
    final res = VietnameseLunar.convertSolarToLunar(day, month, year);
    return LunarDate(day: res[0], month: res[1], year: res[2], isLeap: res[3] == 1);
  }

  static SolarDate? getNextMemorialSolarForYear(int lunarMonth, int lunarDay, bool? isLeap, int targetYear) {
    try {
      final s = lunarToSolar(targetYear, lunarMonth, lunarDay, isLeap: isLeap ?? false);
      return s;
    } catch (_) {
      return null;
    }
  }

  static DateTime? getNextOccurrence(int lunarMonth, int lunarDay, bool? isLeap, {DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    final refYear = ref.year;
    final todayStart = DateTime(ref.year, ref.month, ref.day);

    for (int year = refYear; year <= refYear + 2; year++) {
      final solarInfo = getNextMemorialSolarForYear(lunarMonth, lunarDay, isLeap, year);
      if (solarInfo != null) {
        final solarDate = DateTime(solarInfo.year, solarInfo.month, solarInfo.day);
        if (!solarDate.isBefore(todayStart)) {
          return solarDate;
        }
      }
    }
    return null;
  }

  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }
}
