class LatestAlarm {
  final int id;
  final int ruleId;
  final String ruleName;
  final String category;
  final String level;
  final String status;
  final String message;
  final String createdAt;

  LatestAlarm({
    required this.id,
    required this.ruleId,
    required this.ruleName,
    required this.category,
    required this.level,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory LatestAlarm.fromJson(Map<String, dynamic> json) {
    return LatestAlarm(
      id: json['id'] ?? 0,
      ruleId: json['rule_id'] ?? 0,
      ruleName: json['rule_name'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}


class DeviceCard {
  final int id;
  final String deviceId;
  final String name;
  final String status;
  final String location;
  final int ownerId;
  final String lastOnlineAt;
  final String lastDataAt;
  final int pendingAlarmCount;
  final String contactSummary;
  final LatestAlarm? latestAlarm;

  DeviceCard({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.status,
    required this.location,
    required this.ownerId,
    required this.lastOnlineAt,
    required this.lastDataAt,
    required this.pendingAlarmCount,
    required this.contactSummary,
    required this.latestAlarm,
  });

  factory DeviceCard.fromJson(Map<String, dynamic> json) {
    return DeviceCard(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      lastOnlineAt: json['last_online_at'] ?? '',
      lastDataAt: json['last_data_at'] ?? '',
      pendingAlarmCount: json['pending_alarm_count'] ?? 0,
      contactSummary: json['contact_summary'] ?? '',
      latestAlarm: json['latest_alarm'] == null
          ? null
          : LatestAlarm.fromJson(json['latest_alarm']),
    );
  }
}
