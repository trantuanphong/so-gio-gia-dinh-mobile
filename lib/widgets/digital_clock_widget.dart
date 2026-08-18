import 'package:flutter/material.dart';

class DigitalClockWidget extends StatelessWidget {
  final DateTime now;
  final String lunarStr;
  final String canChiDay;
  final String canChiYear;

  const DigitalClockWidget({
    super.key,
    required this.now,
    required this.lunarStr,
    required this.canChiDay,
    required this.canChiYear,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    final solarStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC), // Cornsilk background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8860B), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B0000),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text("Dương lịch", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(solarStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              Container(height: 24, width: 1, color: Colors.amber),
              Column(
                children: [
                  const Text("Âm lịch", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(lunarStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Ngày $canChiDay - Năm $canChiYear",
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}
