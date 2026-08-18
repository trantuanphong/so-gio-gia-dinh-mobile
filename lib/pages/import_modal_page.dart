import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/storage_service.dart';

class ImportModalPage extends StatefulWidget {
  final LocalStorageService storage;
  final String currentFamilyId;

  const ImportModalPage({
    super.key,
    required this.storage,
    required this.currentFamilyId,
  });

  @override
  State<ImportModalPage> createState() => _ImportModalPageState();
}

class _ImportModalPageState extends State<ImportModalPage> {
  final _textController = TextEditingController();
  Map<String, dynamic>? _importedData;
  String? _errorMsg;

  void _onScan(BarcodeCapture capture) {
    if (_importedData != null) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _processJson(code);
      }
    }
  }

  void _processJson(String jsonStr) {
    final res = widget.storage.parseImportData(jsonStr);
    setState(() {
      if (res['valid'] == true) {
        _importedData = res['data'] as Map<String, dynamic>;
        _errorMsg = null;
      } else {
        _errorMsg = res['error'] as String;
      }
    });
  }

  void _confirmMerge() {
    if (_importedData != null) {
      widget.storage.importFamilyMerge(_importedData!, widget.currentFamilyId);
      Navigator.pop(context, true);
    }
  }

  void _confirmNewGroup() {
    if (_importedData != null) {
      widget.storage.importFamilyNewGroup(_importedData!);
      Navigator.pop(context, true);
    }
  }

  void _confirmOverwrite() {
    if (_importedData != null) {
      widget.storage.importFamilyOverwrite(_importedData!, widget.currentFamilyId);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFam = widget.storage.getFamilies().firstWhere((f) => f.id == widget.currentFamilyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập dữ liệu ngày giỗ"),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_importedData == null) ...[
              const Text("1. Quét mã QR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  onDetect: _onScan,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Hoặc 2. Dán chuỗi dữ liệu JSON / Mã chia sẻ:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Dán mã chia sẻ vào đây...",
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _processJson(_textController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Kiểm tra dữ liệu"),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ]
            ] else ...[
              Text(
                "Đã phát hiện dữ liệu: ${_importedData!['familyName']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
              ),
              Text("Số lượng ngày giỗ: ${(_importedData!['memorials'] as List).length}"),
              const SizedBox(height: 24),
              const Text("Chọn hình thức nhập dữ liệu:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Colors.amber.shade50,
                title: Text("1. Gộp vào '${currentFam.name}'"),
                subtitle: const Text("Thêm các ngày giỗ mới vào nhóm hiện tại, giữ lại dữ liệu cũ."),
                onTap: _confirmMerge,
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.blue.shade50,
                title: Text("2. Tạo nhóm gia đình mới ('${_importedData!['familyName']}')"),
                subtitle: const Text("Tạo thêm một dòng họ riêng với toàn bộ ngày giỗ này."),
                onTap: _confirmNewGroup,
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.red.shade50,
                title: Text("3. Ghi đè nhóm hiện tại ('${currentFam.name}')"),
                subtitle: const Text("Xóa sạch toàn bộ ngày giỗ hiện tại của nhóm này và thay bằng dữ liệu mới."),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text("Cảnh báo ghi đè"),
                      content: Text("Hành động này sẽ xóa toàn bộ ngày giỗ hiện tại trong '${currentFam.name}'. Bạn chắc chắn chứ?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(c);
                            _confirmOverwrite();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: const Text("Đồng ý Ghi đè"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() => _importedData = null),
                child: const Text("Quay lại"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
