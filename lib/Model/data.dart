// 统一数字
double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

// 字段选择
class DeviceFieldOption {
  final String key;
  final String label;
  final String unit;
  final String dataType;
  final bool baselineEnabled;

  const DeviceFieldOption({
    required this.key,
    required this.label,
    required this.unit,
    required this.dataType,
    required this.baselineEnabled,
  });

  factory DeviceFieldOption.fromJson(Map<String, dynamic> json) {
    return DeviceFieldOption(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      dataType: json['data_type']?.toString() ?? '',
      baselineEnabled: json['baseline_enabled'] == true,
    );
  }
}

// 数据点
class TimeSeriesPoint {
  final DateTime timestamp;
  final double value;

  const TimeSeriesPoint({required this.timestamp, required this.value});

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: DateTime.parse(json['timestamp'].toString()),
      value: _toDouble(json['value']) ?? 0,
    );
  }
}

// 曲线
class TimeSeriesLine {
  final String field;
  final String label;
  final String unit;
  final List<TimeSeriesPoint> points;

  const TimeSeriesLine({
    required this.field,
    required this.label,
    required this.unit,
    required this.points,
  });

  factory TimeSeriesLine.fromJson(Map<String, dynamic> json) {
    final List list = json['points'] as List? ?? [];

    return TimeSeriesLine(
      field: json['field']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      points: list
          .map(
            (item) => TimeSeriesPoint.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class TimeSeriesResponse {
  final String interval;
  final String appliedInterval;
  final List<TimeSeriesLine> series;

  const TimeSeriesResponse({
    required this.interval,
    required this.appliedInterval,
    required this.series,
  });

  factory TimeSeriesResponse.fromJson(Map<String, dynamic> json) {
    final List list = json['series'] as List? ?? [];

    return TimeSeriesResponse(
      interval: json['interval']?.toString() ?? '',
      appliedInterval: json['applied_interval']?.toString() ?? '',
      series: list
          .map(
            (item) =>
                TimeSeriesLine.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
