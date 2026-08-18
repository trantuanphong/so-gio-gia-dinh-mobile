import 'dart:async';
import 'package:flutter/material.dart';
import 'models/app_models.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'pages/memorial_detail_page.dart';
import 'pages/memorial_form_page.dart';
import 'pages/family_management_page.dart';
import 'widgets/traditional_header.dart';
import 'widgets/family_filter_bar.dart';
import 'widgets/memorial_card.dart';
import 'widgets/alert_banner.dart';
import 'constants/app_theme.dart';
import 'utils/lunar_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  await storage.init();
  await NotificationService.init();

  runApp(SoGioGiaDinhApp(storage: storage));
}

class SoGioGiaDinhApp extends StatelessWidget {
  final LocalStorageService storage;

  const SoGioGiaDinhApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sổ Giỗ Gia Đình',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: HomePage(storage: storage),
    );
  }
}

class HomePage extends StatefulWidget {
  final LocalStorageService storage;

  const HomePage({super.key, required this.storage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _now;
  Timer? _timer;
  String _filterFamilyId = "ALL";

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _addMemorial() async {
    final families = widget.storage.getFamilies();
    final targetFamilyId = _filterFamilyId == "ALL"
        ? (families.isNotEmpty ? families.first.id : "default")
        : _filterFamilyId;

    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MemorialFormPage(
          storage: widget.storage,
          familyId: targetFamilyId,
        ),
      ),
    );

    if (res == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final families = widget.storage.getFamilies();
    final memorials = _filterFamilyId == "ALL"
        ? widget.storage.getMemorials()
        : widget.storage.getMemorials(_filterFamilyId);

    // Sắp xếp ngày giỗ theo số ngày còn lại
    final sortedMemorials = List<Memorial>.from(memorials)..sort((a, b) {
      final nextA = LunarUtils.getNextOccurrence(a.lunarMonth, a.lunarDay, false);
      final nextB = LunarUtils.getNextOccurrence(b.lunarMonth, b.lunarDay, false);
      final daysA = nextA != null ? LunarUtils.daysBetween(_now, nextA) : 999;
      final daysB = nextB != null ? LunarUtils.daysBetween(_now, nextB) : 999;
      return daysA.compareTo(daysB);
    });

    final activeFamilyObj = families.firstWhere(
      (f) => f.id == _filterFamilyId,
      orElse: () => Family(id: "ALL", name: "Tất cả", ownerUserId: "user"),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Sơn Mài
                TraditionalHeader(
                  today: _now,
                  onFamilyClick: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => FamilyManagementPage(
                          storage: widget.storage,
                          currentFamilyId: _filterFamilyId == "ALL" ? (families.isNotEmpty ? families.first.id : "") : _filterFamilyId,
                        ),
                      ),
                    );
                    _refresh();
                  },
                ),
                const SizedBox(height: 14),

                // Family Filter Bar
                FamilyFilterBar(
                  filterFamilyId: _filterFamilyId,
                  families: families,
                  storage: widget.storage,
                  onSelectFamily: (id) {
                    setState(() {
                      _filterFamilyId = id;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Alert Banner
                AlertBanner(
                  upcomingCount: sortedMemorials.where((m) {
                    final next = LunarUtils.getNextOccurrence(m.lunarMonth, m.lunarDay, false);
                    final days = next != null ? LunarUtils.daysBetween(_now, next) : 999;
                    return days <= 7;
                  }).length,
                  onTap: () {},
                ),
                const SizedBox(height: 14),

                // Tiêu đề danh sách
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filterFamilyId == "ALL" ? "Danh sách ngày giỗ sắp tới" : "Ngày giỗ (${activeFamilyObj.name})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkBlack,
                      ),
                    ),
                    Text(
                      "${sortedMemorials.length} mục",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Danh sách ngày giỗ
                if (sortedMemorials.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      border: Border.all(color: AppTheme.subtleBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: AppTheme.dongGold),
                        SizedBox(height: 12),
                        Text(
                          "Chưa có ngày giỗ nào",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.inkBlack),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Bấm nút \"+ THÊM NGÀY GIỖ MỚI\" bên dưới để lưu thông tin ngày cúng giỗ người thân.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedMemorials.length,
                    itemBuilder: (ctx, idx) {
                      final m = sortedMemorials[idx];
                      return MemorialCard(
                        memorial: m,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => MemorialDetailPage(
                                storage: widget.storage,
                                memorialId: m.id,
                              ),
                            ),
                          );
                          _refresh();
                        },
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppTheme.paperBg,
          border: Border(top: BorderSide(color: AppTheme.subtleBorder)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lacRed,
            foregroundColor: const Color(0xFFFFFDF9),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppTheme.dongGold),
            ),
          ),
          onPressed: _addMemorial,
          child: const Text(
            "THÊM NGÀY GIỖ MỚI",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
