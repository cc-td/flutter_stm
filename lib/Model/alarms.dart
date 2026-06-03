
class AlarmRecord {
  final int id;
  final String deviceId;
  final String displayMode;
  final String displayCategory;
  final String displaySummary;
  final String level;
  final String status;
  final bool canHandle;
  final String createdAt;

  const AlarmRecord({
    required this.id,
    required this.deviceId,
    required this.displayMode,
    required this.displayCategory,
    required this.displaySummary,
    required this.level,
    required this.status,
    required this.canHandle,
    required this.createdAt,
  });

  factory AlarmRecord.fromJson(Map<String, dynamic> json) {
    return AlarmRecord(
      id: json['id'] ?? 0,
      deviceId: json['device_id']?.toString() ?? '',
      displayMode: json['display_mode']?.toString() ?? '',
      displayCategory: json['display_category']?.toString() ?? '',
      displaySummary: json['display_summary']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      canHandle: json['can_handle'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}


class AlarmPage {
  final List<AlarmRecord> list;
  final int total;
  final int page;
  final int pageSize;

  const AlarmPage({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory AlarmPage.fromJson(Map<String, dynamic> json) {
    final List list = json['list'] as List? ?? [];

    return AlarmPage(
      list: list
          .map(
            (item) =>
                AlarmRecord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
    );
  }
}

