import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../utils/lunar_utils.dart';
import 'memorial_form_page.dart';

class MemorialDetailPage extends StatefulWidget {
  final LocalStorageService storage;
  final String memorialId;

  const MemorialDetailPage({
    super.key,
    required this.storage,
    required this.memorialId,
  });

  @override
  State<MemorialDetailPage> createState() => _MemorialDetailPageState();
}

class _MemorialDetailPageState extends State<MemorialDetailPage> {
  late Memorial? _memorial;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _memorial = widget.storage.getMemorial(widget.memorialId);
    });
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xóa ngày giỗ"),
        content: Text("Bạn có chắc muốn xóa ngày giỗ của ${_memorial?.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              widget.storage.deleteMemorial(widget.memorialId);
              Navigator.pop(c);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  void _edit() async {
    if (_memorial == null) return;
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MemorialFormPage(
          storage: widget.storage,
          familyId: _memorial!.familyId,
          memorial: _memorial,
        ),
      ),
    );
    if (res == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memorial == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết ngày giỗ")),
        body: const Center(child: Text("Không tìm thấy ngày giỗ")),
      );
    }

    final mem = _memorial!;
    final nextOccur = LunarUtils.getNextOccurrence(mem.lunarMonth, mem.lunarDay, false);
    final daysLeft = nextOccur != null ? LunarUtils.daysBetween(DateTime.now(), nextOccur) : null;
    final reminders = widget.storage.getRemindersForMemorial(mem.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(mem.name),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _edit,
            tooltip: "Chỉnh sửa ngày giỗ",
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
            tooltip: "Xóa ngày giỗ",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFFFFF8DC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      mem.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
                    ),
                    if (mem.relationship != null && mem.relationship!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text("Vai vế: ${mem.relationship}", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                    ],
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("Ngày Âm Lịch", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              "${mem.lunarDay.toString().padLeft(2, '0')}/${mem.lunarMonth.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Dương Lịch Tới", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              nextOccur != null ? "${nextOccur.day}/${nextOccur.month}/${nextOccur.year}" : "--",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (daysLeft != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          daysLeft == 0 ? "HÔM NAY LÀ NGÀY GIỖ" : "Còn $daysLeft ngày nữa",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (mem.note != null && mem.note!.isNotEmpty) ...[
              const Text("Ghi chú:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(mem.note!, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 20),
            ],
            const Text("Cấu hình nhắc nhở:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
            const SizedBox(height: 6),
            ...reminders.map((r) {
              final label = r.daysBefore == 0 ? "Nhắc nhở đúng ngày giỗ (8:00 sáng)" : "Nhắc nhở trước ${r.daysBefore} ngày (8:00 sáng)";
              return ListTile(
                leading: const Icon(Icons.alarm, color: Color(0xFF8B0000)),
                title: Text(label),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            }),
          ],
        ),
      ),
    );
  }
}
