import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TraditionalHeader extends StatelessWidget {
  final DateTime today;
  final VoidCallback onFamilyClick;

  const TraditionalHeader({
    super.key,
    required this.today,
    required this.onFamilyClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.lacDarkRed, AppTheme.lacRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.dongGold),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40580A0A),
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SỔ GIỖ GIA ĐÌNH",
                    style: TextStyle(
                      color: Color(0xFFFFFDF9),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Ghi nhớ cội nguồn",
                    style: TextStyle(
                      color: AppTheme.dongGold,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppTheme.dongGold, size: 28),
            onPressed: onFamilyClick,
            tooltip: "Quản lý Gia đình",
          ),
        ],
      ),
    );
  }
}
