import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'notification_service.dart';

class LocalStorageService {
  static const String _storageKey = "nhac_lich_gio_v1";
  static const _uuid = Uuid();

  AppState _state = AppState(users: [], families: [], memorials: [], reminders: []);

  AppState get state => _state;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        _state = AppState.fromJson(decoded);
      } catch (e) {
        _state = AppState(users: [], families: [], memorials: [], reminders: []);
      }
    }
    if (_state.families.isEmpty) {
      final defaultFam = Family(id: _uuid.v4(), name: 'Gia đình mặc định', ownerUserId: 'default_user');
      _state.families.add(defaultFam);
      await saveState();
    }
  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_state.toJson()));
    await NotificationService.scheduleAllReminders(_state);
  }

  List<Family> getFamilies() => _state.families;

  Family createFamily(String name, String ownerUserId) {
    final fam = Family(id: _uuid.v4(), name: name, ownerUserId: ownerUserId);
    _state.families.add(fam);
    saveState();
    return fam;
  }

  Family? updateFamily(String id, String name) {
    final idx = _state.families.indexWhere((f) => f.id == id);
    if (idx < 0) return null;
    final updated = Family(id: id, name: name, ownerUserId: _state.families[idx].ownerUserId);
    _state.families[idx] = updated;
    saveState();
    return updated;
  }

  bool deleteFamily(String id) {
    if (_state.families.length <= 1) return false;
    _state.families.removeWhere((f) => f.id == id);
    final memIds = _state.memorials.where((m) => m.familyId == id).map((m) => m.id).toSet();
    _state.memorials.removeWhere((m) => m.familyId == id);
    _state.reminders.removeWhere((r) => memIds.contains(r.memorialId));
    saveState();
    return true;
  }

  List<Memorial> getMemorials([String? familyId]) {
    if (familyId == null || familyId == "ALL") {
      return List.unmodifiable(_state.memorials);
    }
    return _state.memorials.where((m) => m.familyId == familyId).toList();
  }

  Memorial? getMemorial(String id) {
    try {
      return _state.memorials.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Memorial addMemorial({
    required String familyId,
    required String name,
    String? relationship,
    required int lunarDay,
    required int lunarMonth,
    bool? isLeapMonth,
    String? note,
    required List<int> reminderDaysBefore,
  }) {
    final id = _uuid.v4();
    final mem = Memorial(
      id: id,
      familyId: familyId,
      name: name,
      relationship: relationship,
      lunarDay: lunarDay,
      lunarMonth: lunarMonth,
      isLeapMonth: isLeapMonth,
      note: note,
    );
    _state.memorials.add(mem);

    for (final days in reminderDaysBefore) {
      _state.reminders.add(Reminder(
        id: _uuid.v4(),
        memorialId: id,
        daysBefore: days,
        enabled: true,
      ));
    }

    saveState();
    return mem;
  }

  Memorial? updateMemorial(
    String id, {
    required String name,
    String? relationship,
    required int lunarDay,
    required int lunarMonth,
    bool? isLeapMonth,
    String? note,
    required List<int> reminderDaysBefore,
  }) {
    final idx = _state.memorials.indexWhere((m) => m.id == id);
    if (idx < 0) return null;

    final updated = Memorial(
      id: id,
      familyId: _state.memorials[idx].familyId,
      name: name,
      relationship: relationship,
      lunarDay: lunarDay,
      lunarMonth: lunarMonth,
      isLeapMonth: isLeapMonth,
      note: note,
    );
    _state.memorials[idx] = updated;

    _state.reminders.removeWhere((r) => r.memorialId == id);
    for (final days in reminderDaysBefore) {
      _state.reminders.add(Reminder(
        id: _uuid.v4(),
        memorialId: id,
        daysBefore: days,
        enabled: true,
      ));
    }

    saveState();
    return updated;
  }

  bool deleteMemorial(String id) {
    _state.memorials.removeWhere((m) => m.id == id);
    _state.reminders.removeWhere((r) => r.memorialId == id);
    saveState();
    return true;
  }

  List<Reminder> getRemindersForMemorial(String memorialId) {
    return _state.reminders.where((r) => r.memorialId == memorialId).toList();
  }

  String? exportFamilyData(String familyId) {
    final fam = _state.families.firstWhere((f) => f.id == familyId, orElse: () => Family(id: '', name: '', ownerUserId: ''));
    if (fam.id.isEmpty) return null;

    final mems = _state.memorials.where((m) => m.familyId == familyId).map((m) {
      final rems = _state.reminders.where((r) => r.memorialId == m.id).map((r) => {
        'days_before': r.daysBefore,
        'enabled': r.enabled,
      }).toList();

      return {
        'name': m.name,
        'relationship': m.relationship,
        'lunar_day': m.lunarDay,
        'lunar_month': m.lunarMonth,
        'is_leap_month': m.isLeapMonth,
        'note': m.note,
        'reminders': rems,
      };
    }).toList();

    final payload = {
      'familyName': fam.name,
      'familyId': fam.id,
      'exportedAt': DateTime.now().toIso8601String(),
      'format': 'nhac-lich-gio:v1',
      'memorials': mems,
    };

    return jsonEncode(payload);
  }

  Map<String, dynamic> parseImportData(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) return {'valid': false, 'error': 'Nội dung trống.'};
      final obj = jsonDecode(jsonString);
      if (obj is! Map<String, dynamic>) return {'valid': false, 'error': 'Định dạng JSON không hợp lệ.'};
      if (obj['format'] != 'nhac-lich-gio:v1' && obj['familyName'] == null) {
        return {'valid': false, 'error': 'Dữ liệu không đúng cấu trúc Ngày Giỗ Gia Đình.'};
      }
      if (obj['familyName'] == null || obj['familyName'] is! String) {
        return {'valid': false, 'error': 'Thiếu thông tin tên nhóm gia đình.'};
      }
      if (obj['memorials'] == null || obj['memorials'] is! List) {
        return {'valid': false, 'error': 'Thiếu danh sách ngày giỗ trong dữ liệu.'};
      }
      return {'valid': true, 'data': obj};
    } catch (_) {
      return {'valid': false, 'error': 'Dữ liệu không phải chuỗi JSON hợp lệ.'};
    }
  }

  Family importFamilyMerge(Map<String, dynamic> payload, String targetFamilyId) {
    final memorialsData = payload['memorials'] as List;
    for (final item in memorialsData) {
      final memMap = item as Map<String, dynamic>;
      final rems = (memMap['reminders'] as List? ?? [])
          .map((r) => (r['days_before'] as num).toInt())
          .toList();
      addMemorial(
        familyId: targetFamilyId,
        name: memMap['name'] as String,
        relationship: memMap['relationship'] as String?,
        lunarDay: (memMap['lunar_day'] as num).toInt(),
        lunarMonth: (memMap['lunar_month'] as num).toInt(),
        isLeapMonth: memMap['is_leap_month'] as bool?,
        note: memMap['note'] as String?,
        reminderDaysBefore: rems.isEmpty ? [1] : rems,
      );
    }
    return _state.families.firstWhere((f) => f.id == targetFamilyId);
  }

  Family importFamilyNewGroup(Map<String, dynamic> payload, {String? customName}) {
    final name = (customName != null && customName.trim().isNotEmpty)
        ? customName.trim()
        : payload['familyName'] as String;
    final newFam = createFamily(name, 'imported_user');
    importFamilyMerge(payload, newFam.id);
    return newFam;
  }

  Family importFamilyOverwrite(Map<String, dynamic> payload, String targetFamilyId) {
    final memIds = _state.memorials.where((m) => m.familyId == targetFamilyId).map((m) => m.id).toSet();
    _state.memorials.removeWhere((m) => m.familyId == targetFamilyId);
    _state.reminders.removeWhere((r) => memIds.contains(r.memorialId));
    saveState();
    return importFamilyMerge(payload, targetFamilyId);
  }
}
