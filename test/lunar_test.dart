// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:so_gio_gia_dinh_mobile/utils/lunar_utils.dart';

void main() {
  test('Lunar conversion test', () {
    // 18/08/2026 solar -> lunar
    final lunar = LunarUtils.solarToLunar(2026, 8, 18);
    print("2026-08-18 solar => Lunar: ${lunar.day}/${lunar.month}/${lunar.year}");

    // Convert back lunar to solar
    final solar = LunarUtils.lunarToSolar(lunar.year, lunar.month, lunar.day, isLeap: lunar.isLeap);
    print("Lunar ${lunar.day}/${lunar.month}/${lunar.year} => Solar: ${solar.day}/${solar.month}/${solar.year}");

    expect(solar.year, 2026);
    expect(solar.month, 8);
    expect(solar.day, 18);
  });
}
