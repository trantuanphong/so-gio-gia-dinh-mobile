import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/app_models.dart';
import '../utils/lunar_utils.dart';
import '../constants/app_theme.dart';

class MemorialCard extends StatelessWidget {
  final Memorial memorial;
  final VoidCallback onTap;

  const MemorialCard({
    super.key,
    required this.memorial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextOccur = LunarUtils.getNextOccurrence(memorial.lunarMonth, memorial.lunarDay, false);
    final daysLeft = nextOccur != null ? LunarUtils.daysBetween(DateTime.now(), nextOccur) : null;
    final lunarDateStr = "${memorial.lunarDay.toString().padLeft(2, '0')}/${memorial.lunarMonth.toString().padLeft(2, '0')}";
    final solarDateStr = nextOccur != null ? "${nextOccur.day}/${nextOccur.month}/${nextOccur.year}" : "--";

    String daysText = daysLeft != null ? "Còn $daysLeft ngày" : "";
    Color badgeBg = const Color(0xFFF4EEE1);
    Color badgeText = AppTheme.inkBlack;

    if (daysLeft == 0) {
      daysText = "HÔM NAY";
      badgeBg = AppTheme.lacRed;
      badgeText = Colors.white;
    } else if (daysLeft == 1) {
      daysText = "NGÀY MAI";
      badgeBg = AppTheme.lacDarkRed;
      badgeText = Colors.white;
    }

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          color: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppTheme.subtleBorder),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppTheme.lacRed, width: 4)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memorial.relationship != null && memorial.relationship!.isNotEmpty
                              ? "${memorial.relationship}: ${memorial.name}"
                              : memorial.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.inkBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "Âm lịch: $lunarDateStr",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.lacRed),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Dương: $solarDateStr",
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (daysText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.subtleBorder),
                      ),
                      child: Text(
                        daysText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeText),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: SvgPicture.asset(
            'assets/svgs/corner-pattern.svg',
            width: 14,
            height: 14,
          ),
        ),
      ],
    );
  }
}
