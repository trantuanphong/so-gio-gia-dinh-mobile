import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../constants/app_theme.dart';

class FamilyFilterBar extends StatelessWidget {
  final String filterFamilyId;
  final List<Family> families;
  final LocalStorageService storage;
  final ValueChanged<String> onSelectFamily;

  const FamilyFilterBar({
    super.key,
    required this.filterFamilyId,
    required this.families,
    required this.storage,
    required this.onSelectFamily,
  });

  @override
  Widget build(BuildContext context) {
    final totalMemorialsCount = storage.getMemorials().length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.subtleBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DANH SÁCH GIA ĐÌNH",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lacDarkRed,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "${filterFamilyId == 'ALL' ? totalMemorialsCount : storage.getMemorials(filterFamilyId).length} ngày giỗ",
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  id: "ALL",
                  label: "Tất cả ($totalMemorialsCount)",
                  isSelected: filterFamilyId == "ALL",
                ),
                ...families.map((f) {
                  final count = storage.getMemorials(f.id).length;
                  return _buildFilterChip(
                    id: f.id,
                    label: "${f.name} ($count)",
                    isSelected: filterFamilyId == f.id,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String id, required String label, required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onSelectFamily(id),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.lacRed : const Color(0xFFF4EEE1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppTheme.lacDarkRed : AppTheme.subtleBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFFDF9) : AppTheme.inkBlack,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
