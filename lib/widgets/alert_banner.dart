import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final int upcomingCount;
  final VoidCallback onTap;

  const AlertBanner({
    super.key,
    required this.upcomingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFEEBA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF856404)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Sắp tới có $upcomingCount ngày giỗ cần chú ý!",
                style: const TextStyle(
                  color: Color(0xFF856404),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF856404)),
          ],
        ),
      ),
    );
  }
}
