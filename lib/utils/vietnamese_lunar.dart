import 'dart:math' as math;

const double piValue = math.pi;
const double j2000 = 2451545.0;
const double lunarEpoch = 2415021.076998695;
const double synodicMonth = 29.530588853;
const double vietnamTimezone = 7.0;

class VietnameseLunar {
  static const List<String> canList = [
    "Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"
  ];
  static const List<String> chiList = [
    "Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"
  ];

  static int integer(double value) => value.floor();

  static double degreesToRadians(double degrees) => (degrees * piValue) / 180.0;

  static double normalizeDegrees(double degrees) {
    return degrees - 360.0 * (degrees / 360.0).floor();
  }

  static double solarDateToJulianDay(int day, int month, int year) {
    int adjustedMonth = ((14 - month) ~/ 12);
    int adjustedYear = year + 4800 - adjustedMonth;
    int adjustedMonthIndex = month + 12 * adjustedMonth - 3;

    return (day +
            ((153 * adjustedMonthIndex + 2) ~/ 5) +
            365 * adjustedYear +
            (adjustedYear ~/ 4) -
            (adjustedYear ~/ 100) +
            (adjustedYear ~/ 400) -
            32045)
        .toDouble();
  }

  static List<int> julianDayToSolarDate(double jd) {
    int l = (jd + 68569).floor();
    int n = ((4 * l) ~/ 146097);
    int l1 = l - ((146097 * n + 3) ~/ 4);
    int i = ((4000 * (l1 + 1)) ~/ 1461001);
    int l2 = l1 - ((1461 * i) ~/ 4) + 31;
    int j = ((80 * l2) ~/ 2447);
    int day = l2 - ((2447 * j) ~/ 80);
    int l3 = (j ~/ 11);
    int month = j + 2 - 12 * l3;
    int year = 100 * (n - 49) + i + l3;

    return [day, month, year];
  }

  static double getNewMoonDay(int k, {double timeZone = vietnamTimezone}) {
    double time = k / 1236.85;
    double timeSquared = time * time;
    double timeCubed = timeSquared * time;
    double radians = piValue / 180.0;

    double julianDay = 2415020.75933 +
        synodicMonth * k +
        0.0001178 * timeSquared -
        0.000000155 * timeCubed;

    julianDay += 0.00033 *
        math.sin(degreesToRadians(166.56 + 132.87 * time - 0.009173 * timeSquared));

    double sunAnomaly = 359.2242 +
        29.10535608 * k -
        0.0000333 * timeSquared -
        0.00000347 * timeCubed;

    double moonAnomaly = 306.0253 +
        385.81691806 * k +
        0.0107306 * timeSquared +
        0.00001236 * timeCubed;

    double moonLatitude = 21.2964 +
        390.67050646 * k -
        0.0016528 * timeSquared -
        0.00000239 * timeCubed;

    double correction = (0.1734 - 0.000393 * time) * math.sin(sunAnomaly * radians) +
        0.0021 * math.sin(2 * sunAnomaly * radians) -
        0.4068 * math.sin(moonAnomaly * radians) +
        0.0161 * math.sin(2 * moonAnomaly * radians) -
        0.0004 * math.sin(3 * moonAnomaly * radians) +
        0.0104 * math.sin(2 * moonLatitude * radians) -
        0.0051 * math.sin((sunAnomaly + moonAnomaly) * radians) -
        0.0074 * math.sin((sunAnomaly - moonAnomaly) * radians) +
        0.0004 * math.sin((2 * moonLatitude + sunAnomaly) * radians) -
        0.0004 * math.sin((2 * moonLatitude - sunAnomaly) * radians) -
        0.0006 * math.sin((2 * moonLatitude + moonAnomaly) * radians) +
        0.001 * math.sin((2 * moonLatitude - moonAnomaly) * radians) +
        0.0005 * math.sin((2 * moonAnomaly + sunAnomaly) * radians);

    double deltaT = time < -11
        ? 0.001 +
            0.000839 * time +
            0.0002261 * timeSquared -
            0.00000845 * timeCubed -
            0.000000081 * time * timeCubed
        : -0.000278 + 0.000265 * time + 0.000262 * timeSquared;

    double newMoonJulianDay = julianDay + correction - deltaT;

    return (newMoonJulianDay + 0.5 + timeZone / 24.0).floorToDouble();
  }

  static int getSunLongitude(double julianDay, {double timeZone = vietnamTimezone}) {
    double time = (julianDay - j2000 - timeZone / 24.0) / 36525.0;
    double timeSquared = time * time;

    double meanAnomaly = 357.5291 +
        35999.0503 * time -
        0.0001559 * timeSquared -
        0.00000048 * time * timeSquared;

    double meanLongitude = 280.46645 + 36000.76983 * time + 0.0003032 * timeSquared;

    double solarEquation = (1.9146 - 0.004817 * time - 0.000014 * timeSquared) *
            math.sin(degreesToRadians(meanAnomaly)) +
        (0.019993 - 0.000101 * time) * math.sin(degreesToRadians(2 * meanAnomaly)) +
        0.00029 * math.sin(degreesToRadians(3 * meanAnomaly));

    double trueLongitude = meanLongitude + solarEquation;
    double normalizedLongitude = normalizeDegrees(trueLongitude);

    return (normalizedLongitude / 30.0).floor();
  }

  static double getLunarMonth11(int year, {double timeZone = vietnamTimezone}) {
    double offset = solarDateToJulianDay(31, 12, year) - 2415021;
    int newMoonIndex = (offset / synodicMonth).floor();
    double monthStart = getNewMoonDay(newMoonIndex, timeZone: timeZone);
    int solarLongitude = getSunLongitude(monthStart, timeZone: timeZone);

    if (solarLongitude >= 9) {
      monthStart = getNewMoonDay(newMoonIndex - 1, timeZone: timeZone);
    }

    return monthStart;
  }

  static int getLeapMonthOffset(double lunarMonth11Start, {double timeZone = vietnamTimezone}) {
    int newMoonIndex = (0.5 + (lunarMonth11Start - lunarEpoch) / synodicMonth).floor();
    int previousSolarLongitude = 0;
    int monthOffset = 1;

    int currentSolarLongitude = getSunLongitude(
      getNewMoonDay(newMoonIndex + monthOffset, timeZone: timeZone),
      timeZone: timeZone,
    );

    while (currentSolarLongitude != previousSolarLongitude && monthOffset < 14) {
      previousSolarLongitude = currentSolarLongitude;
      monthOffset++;
      currentSolarLongitude = getSunLongitude(
        getNewMoonDay(newMoonIndex + monthOffset, timeZone: timeZone),
        timeZone: timeZone,
      );
    }

    return monthOffset - 1;
  }

  static List<int> convertSolarToLunar(int day, int month, int year, {double timeZone = vietnamTimezone}) {
    double solarJulianDay = solarDateToJulianDay(day, month, year);
    int newMoonIndex = ((solarJulianDay - lunarEpoch) / synodicMonth).floor();

    double lunarMonthStart = getNewMoonDay(newMoonIndex + 1, timeZone: timeZone);
    if (lunarMonthStart > solarJulianDay) {
      lunarMonthStart = getNewMoonDay(newMoonIndex, timeZone: timeZone);
    }

    double lunarMonth11Before;
    double lunarMonth11After;
    int lunarYear;

    double lunarMonth11ThisYear = getLunarMonth11(year, timeZone: timeZone);

    if (lunarMonthStart >= lunarMonth11ThisYear) {
      lunarMonth11Before = lunarMonth11ThisYear;
      lunarMonth11After = getLunarMonth11(year + 1, timeZone: timeZone);
      lunarYear = year;
    } else {
      lunarMonth11Before = getLunarMonth11(year - 1, timeZone: timeZone);
      lunarMonth11After = lunarMonth11ThisYear;
      lunarYear = year;
    }

    int lunarDay = (solarJulianDay - lunarMonthStart + 1).floor();
    int monthOffset = ((lunarMonthStart - lunarMonth11Before) / 29.0).floor();
    int lunarMonth = monthOffset + 11;
    bool isLeapMonth = false;

    int lunarYearMonthCount = ((lunarMonth11After - lunarMonth11Before) / 29.0).floor();

    if (lunarYearMonthCount > 12) {
      int leapMonthOffset = getLeapMonthOffset(lunarMonth11Before, timeZone: timeZone);
      if (monthOffset >= leapMonthOffset) {
        lunarMonth = monthOffset + 10;
      }
      if (monthOffset == leapMonthOffset) {
        isLeapMonth = true;
      }
    }

    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }

    if (lunarMonth >= 11) {
      lunarYear += 1;
    }

    return [lunarDay, lunarMonth, lunarYear, isLeapMonth ? 1 : 0];
  }

  static List<int> convertLunarToSolar(int lunarDay, int lunarMonth, int lunarYear, bool isLeap, {double timeZone = vietnamTimezone}) {
    double lunarMonth11Start;
    double nextLunarMonth11Start;

    if (lunarMonth >= 11) {
      lunarMonth11Start = getLunarMonth11(lunarYear, timeZone: timeZone);
      nextLunarMonth11Start = getLunarMonth11(lunarYear + 1, timeZone: timeZone);
    } else {
      lunarMonth11Start = getLunarMonth11(lunarYear - 1, timeZone: timeZone);
      nextLunarMonth11Start = getLunarMonth11(lunarYear, timeZone: timeZone);
    }

    int newMoonIndex = (0.5 + (lunarMonth11Start - lunarEpoch) / synodicMonth).floor();

    int off = lunarMonth - 11;
    if (off < 0) off += 12;

    int lunarYearMonthCount = ((nextLunarMonth11Start - lunarMonth11Start) / 29.0).floor();

    if (lunarYearMonthCount > 12) {
      int leapMonthOffset = getLeapMonthOffset(lunarMonth11Start, timeZone: timeZone);
      if (isLeap || off >= leapMonthOffset) {
        off += 1;
      }
    }

    double monthStart = getNewMoonDay(newMoonIndex + off, timeZone: timeZone);
    double julianDay = monthStart + lunarDay - 1;

    return julianDayToSolarDate(julianDay);
  }

  static String getCanChiYear(int lunarYear) {
    String can = canList[(lunarYear + 6) % 10];
    String chi = chiList[(lunarYear + 8) % 12];
    return "$can $chi";
  }

  static String getCanChiDay(int day, int month, int year) {
    double jd = solarDateToJulianDay(day, month, year);
    int canIdx = (jd + 9).floor() % 10;
    int chiIdx = (jd + 1).floor() % 12;
    return "${canList[canIdx]} ${chiList[chiIdx]}";
  }
}
