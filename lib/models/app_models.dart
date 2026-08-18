class User {
  final String id;
  final String? zaloUserId;
  final String? displayName;

  User({
    required this.id,
    this.zaloUserId,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'zalo_user_id': zaloUserId,
        'display_name': displayName,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        zaloUserId: json['zalo_user_id'] as String?,
        displayName: json['display_name'] as String?,
      );
}

class Family {
  final String id;
  final String name;
  final String ownerUserId;

  Family({
    required this.id,
    required this.name,
    required this.ownerUserId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner_user_id': ownerUserId,
      };

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerUserId: json['owner_user_id'] as String? ?? 'default_owner',
      );
}

class Memorial {
  final String id;
  final String familyId;
  final String name;
  final String? relationship;
  final int lunarDay;
  final int lunarMonth;
  final bool? isLeapMonth;
  final String? note;
  final String? createdBy;

  Memorial({
    required this.id,
    required this.familyId,
    required this.name,
    this.relationship,
    required this.lunarDay,
    required this.lunarMonth,
    this.isLeapMonth,
    this.note,
    this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_id': familyId,
        'name': name,
        'relationship': relationship,
        'lunar_day': lunarDay,
        'lunar_month': lunarMonth,
        'is_leap_month': isLeapMonth,
        'note': note,
        'created_by': createdBy,
      };

  factory Memorial.fromJson(Map<String, dynamic> json) => Memorial(
        id: json['id'] as String,
        familyId: json['family_id'] as String,
        name: json['name'] as String,
        relationship: json['relationship'] as String?,
        lunarDay: json['lunar_day'] as int,
        lunarMonth: json['lunar_month'] as int,
        isLeapMonth: json['is_leap_month'] as bool?,
        note: json['note'] as String?,
        createdBy: json['created_by'] as String?,
      );
}

class Reminder {
  final String id;
  final String memorialId;
  final String? userId;
  final int daysBefore;
  final bool enabled;

  Reminder({
    required this.id,
    required this.memorialId,
    this.userId,
    required this.daysBefore,
    required this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memorial_id': memorialId,
        'user_id': userId,
        'days_before': daysBefore,
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        memorialId: json['memorial_id'] as String,
        userId: json['user_id'] as String?,
        daysBefore: json['days_before'] as int,
        enabled: json['enabled'] as bool,
      );
}

class AppState {
  final List<User> users;
  final List<Family> families;
  final List<Memorial> memorials;
  final List<Reminder> reminders;

  AppState({
    required this.users,
    required this.families,
    required this.memorials,
    required this.reminders,
  });

  Map<String, dynamic> toJson() => {
        'users': users.map((e) => e.toJson()).toList(),
        'families': families.map((e) => e.toJson()).toList(),
        'memorials': memorials.map((e) => e.toJson()).toList(),
        'reminders': reminders.map((e) => e.toJson()).toList(),
      };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
        users: (json['users'] as List? ?? []).map((e) => User.fromJson(e)).toList(),
        families: (json['families'] as List? ?? []).map((e) => Family.fromJson(e)).toList(),
        memorials: (json['memorials'] as List? ?? []).map((e) => Memorial.fromJson(e)).toList(),
        reminders: (json['reminders'] as List? ?? []).map((e) => Reminder.fromJson(e)).toList(),
      );
}
