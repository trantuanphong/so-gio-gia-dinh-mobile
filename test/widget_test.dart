import 'package:flutter_test/flutter_test.dart';
import 'package:so_gio_gia_dinh_mobile/main.dart';
import 'package:so_gio_gia_dinh_mobile/services/storage_service.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    final storage = LocalStorageService();
    await storage.init();
    await tester.pumpWidget(SoGioGiaDinhApp(storage: storage));
    expect(find.text('Sổ Giỗ Gia Đình'), findsOneWidget);
  });
}
