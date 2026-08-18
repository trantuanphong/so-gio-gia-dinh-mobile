import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import 'export_modal_page.dart';
import 'import_modal_page.dart';

class FamilyManagementPage extends StatefulWidget {
  final LocalStorageService storage;
  final String currentFamilyId;

  const FamilyManagementPage({
    super.key,
    required this.storage,
    required this.currentFamilyId,
  });

  @override
  State<FamilyManagementPage> createState() => _FamilyManagementPageState();
}

class _FamilyManagementPageState extends State<FamilyManagementPage> {
  late List<Family> _families;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _families = widget.storage.getFamilies();
    });
  }

  void _showAddEditDialog([Family? family]) {
    final controller = TextEditingController(text: family != null ? family.name : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(family != null ? "Sửa tên dòng họ" : "Thêm dòng họ mới"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Tên dòng họ / gia đình"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                if (family != null) {
                  widget.storage.updateFamily(family.id, controller.text.trim());
                } else {
                  widget.storage.createFamily(controller.text.trim(), 'user');
                }
                Navigator.pop(ctx);
                _loadData();
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _deleteFamily(Family family) {
    if (_families.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể xóa dòng họ duy nhất còn lại!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xác nhận xóa dòng họ"),
        content: Text("Bạn có chắc muốn xóa '${family.name}' và toàn bộ các ngày giỗ liên quan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              widget.storage.deleteFamily(family.id);
              Navigator.pop(c);
              _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  void _shareFamily(Family family) {
    final jsonStr = widget.storage.exportFamilyData(family.id);
    if (jsonStr != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => ExportModalPage(familyName: family.name, jsonData: jsonStr),
        ),
      );
    }
  }

  void _importData() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ImportModalPage(storage: widget.storage, currentFamilyId: widget.currentFamilyId),
      ),
    );
    if (res == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Dòng họ / Gia đình"),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _importData,
            tooltip: "Nhập dữ liệu từ QR/JSON",
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _families.length,
        itemBuilder: (ctx, idx) {
          final f = _families[idx];
          final memorialCount = widget.storage.getMemorials(f.id).length;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("Số lượng ngày giỗ: $memorialCount"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Color(0xFF8B0000)),
                    onPressed: () => _shareFamily(f),
                    tooltip: "Chia sẻ mã QR",
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showAddEditDialog(f),
                    tooltip: "Sửa tên",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFamily(f),
                    tooltip: "Xóa dòng họ",
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text("NHẬP DỮ LIỆU GIA ĐÌNH"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _importData,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF8B0000),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
