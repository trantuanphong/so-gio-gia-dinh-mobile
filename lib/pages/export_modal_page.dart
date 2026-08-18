import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ExportModalPage extends StatelessWidget {
  final String familyName;
  final String jsonData;

  const ExportModalPage({
    super.key,
    required this.familyName,
    required this.jsonData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chia sẻ dữ liệu - $familyName"),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Quét mã QR bằng ứng dụng Sổ Giỗ Gia Đình để nhập dữ liệu ngày giỗ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
            ),
            const SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: jsonData,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Chia sẻ văn bản / JSON"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Share.share(jsonData, subject: "Dữ liệu ngày giỗ gia đình: $familyName");
              },
            ),
          ],
        ),
      ),
    );
  }
}
