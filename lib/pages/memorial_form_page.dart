import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../utils/lunar_utils.dart';

class MemorialFormPage extends StatefulWidget {
  final LocalStorageService storage;
  final String familyId;
  final Memorial? memorial;

  const MemorialFormPage({
    super.key,
    required this.storage,
    required this.familyId,
    this.memorial,
  });

  @override
  State<MemorialFormPage> createState() => _MemorialFormPageState();
}

class _MemorialFormPageState extends State<MemorialFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _relationship;
  late int _lunarDay;
  late int _lunarMonth;
  final bool _isLeapMonth = false;
  String? _note;
  List<int> _selectedReminders = [1];

  @override
  void initState() {
    super.initState();
    if (widget.memorial != null) {
      _name = widget.memorial!.name;
      _relationship = widget.memorial!.relationship;
      _lunarDay = widget.memorial!.lunarDay;
      _lunarMonth = widget.memorial!.lunarMonth;
      _note = widget.memorial!.note;
      final rems = widget.storage.getRemindersForMemorial(widget.memorial!.id);
      _selectedReminders = rems.map((r) => r.daysBefore).toList();
    } else {
      _name = '';
      _relationship = '';
      _lunarDay = 1;
      _lunarMonth = 1;
      _note = '';
      _selectedReminders = [1];
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.memorial != null) {
        widget.storage.updateMemorial(
          widget.memorial!.id,
          name: _name,
          relationship: _relationship,
          lunarDay: _lunarDay,
          lunarMonth: _lunarMonth,
          isLeapMonth: _isLeapMonth,
          note: _note,
          reminderDaysBefore: _selectedReminders,
        );
      } else {
        widget.storage.addMemorial(
          familyId: widget.familyId,
          name: _name,
          relationship: _relationship,
          lunarDay: _lunarDay,
          lunarMonth: _lunarMonth,
          isLeapMonth: _isLeapMonth,
          note: _note,
          reminderDaysBefore: _selectedReminders,
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextOccur = LunarUtils.getNextOccurrence(_lunarMonth, _lunarDay, false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memorial != null ? "Chỉnh sửa ngày giỗ" : "Thêm ngày giỗ mới"),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(
                labelText: "Tên người thân *",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? "Vui lòng nhập tên" : null,
              onSaved: (val) => _name = val!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _relationship,
              decoration: const InputDecoration(
                labelText: "Quan hệ / Vai vế (Ví dụ: Ông nội, Cụ bà, Chú...)",
                border: OutlineInputBorder(),
              ),
              onSaved: (val) => _relationship = val?.trim(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _lunarDay,
                    decoration: const InputDecoration(labelText: "Ngày (Âm lịch)", border: OutlineInputBorder()),
                    items: List.generate(30, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text("Ngày $d"))).toList(),
                    onChanged: (val) => setState(() => _lunarDay = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _lunarMonth,
                    decoration: const InputDecoration(labelText: "Tháng (Âm lịch)", border: OutlineInputBorder()),
                    items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text("Tháng $m"))).toList(),
                    onChanged: (val) => setState(() => _lunarMonth = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (nextOccur != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF8B0000), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Tương ứng Dương lịch tới: ${nextOccur.day}/${nextOccur.month}/${nextOccur.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              initialValue: _note,
              decoration: const InputDecoration(
                labelText: "Ghi chú (Ví dụ: Địa điểm cúng, món ăn...)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (val) => _note = val,
            ),
            const SizedBox(height: 20),
            const Text("Nhắc nhở trước:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [0, 1, 3, 7].map((days) {
                final isSelected = _selectedReminders.contains(days);
                final label = days == 0 ? "Đúng ngày" : "$days ngày trước";
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedReminders.add(days);
                      } else {
                        _selectedReminders.remove(days);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("LƯU NGÀY GIỖ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
