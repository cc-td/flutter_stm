import 'package:flutter/material.dart';
import 'package:stm_cqut/View/DataComponent/data_trend_chart.dart';
import '../Model/data.dart';
import '../Manager/DeviceService.dart';
import 'DataComponent/data_field_bar.dart';
import '../app_dialog.dart';

class DataView extends StatefulWidget {
  final String? selectedDeviceId;
  final String? selectedDeviceName;
  final bool isActive;

  const DataView({
    super.key,
    required this.selectedDeviceId,
    required this.selectedDeviceName,
    required this.isActive,
  });

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  List<DeviceFieldOption> _fields = [];
  String? _selectedFieldKey;
  bool _fieldsLoading = false;
  TimeSeriesResponse? _series;
  bool _seriesLoading = false;
  DateTime? _windowStart;
  DateTime? _windowEnd;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _preparePage();
    }
  }

  @override
  void didUpdateWidget(covariant DataView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool becameActive = widget.isActive && !oldWidget.isActive;
    final bool deviceChanged =
        widget.selectedDeviceId != oldWidget.selectedDeviceId;

    if (becameActive || (widget.isActive && deviceChanged)) {
      _preparePage();
    }
  }

  Future<void> _preparePage() async {
    final String? deviceId = widget.selectedDeviceId;
    final bool hasDevice = deviceId != null && deviceId.isNotEmpty;
    if (!hasDevice) {
      return;
    }

    setState(() {
      _fieldsLoading = true;
    });

    try {
      final list = await DeviceService.getDeviceFieldOptions(deviceId);
      if (!mounted) return;

      setState(() {
        _fields = list;
        _selectedFieldKey = list.isNotEmpty ? list.first.key : null;
        _fieldsLoading = false;
      });

      if (list.isEmpty) {
        _series = null;
        _windowStart = null;
        _windowEnd = null;
      }

      if (_selectedFieldKey != null) {
        _loadSeries();
      }
    } catch (e) {
      if (!mounted) return;
      final m = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _fieldsLoading = false;
      });

      AppDialog.showMessage(title: "失败", message: m.isEmpty ? "获取字段列表失败" : m);
    }
  }

  void _handleFieldSelected(String key) {
    if (key == _selectedFieldKey) return;
    setState(() {
      _selectedFieldKey = key;
    });
    _loadSeries();
  }

  void _handleWindowPan(Duration delta) {
    final series = _series;
    final start = _windowStart;
    final end = _windowEnd;
    if (series == null || start == null || end == null) return;
    if (series.series.isEmpty) return;
    final points = series.series.first.points;
    if (points.isEmpty) return;

    final DateTime dataMin = points.first.timestamp;
    final DateTime dataMax = DateTime.now();
    DateTime newStart = start.add(delta);
    DateTime newEnd = end.add(delta);

    if (newStart.isBefore(dataMin)) {
      final Duration diff = dataMin.difference(newStart);
      newStart = newStart.add(diff);
      newEnd = newEnd.add(diff);
    }

    if (newEnd.isAfter(dataMax)) {
      final Duration diff = newEnd.difference(dataMax);
      newStart = newStart.subtract(diff);
      newEnd = newEnd.subtract(diff);
    }

    setState(() {
      _windowStart = newStart;
      _windowEnd = newEnd;
    });
  }

  Future<void> _loadSeries() async {
    final String? deviceId = widget.selectedDeviceId;
    final String? fieldKey = _selectedFieldKey;

    if (deviceId == null || deviceId.isEmpty) return;
    if (fieldKey == null) return;

    setState(() {
      _seriesLoading = true;
    });

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 24));

      final response = await DeviceService.getTimeSeries(
        deviceId: deviceId,
        field: fieldKey,
        start: start,
        end: now,
      );
      if (!mounted) return;

      setState(() {
        _series = response;
        _seriesLoading = false;
        _windowEnd = now;
        _windowStart = now.subtract(Duration(hours: 1));
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _seriesLoading = false;
      });

      AppDialog.showMessage(
        title: '失败',
        message: message.isEmpty ? '获取趋势数据失败' : message,
      );
    }
  }

  TimeSeriesLine? _firstLine() {
    final response = _series;
    if (response == null) return null;
    if (response.series.isEmpty) return null;
    return response.series.first;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDevice = widget.selectedDeviceId?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedDeviceName ?? "数据页")),
      body: !hasDevice
          ? Center(child: Text("请先在设备界面选择设备"))
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_fieldsLoading) const LinearProgressIndicator(),

                  if (!_fieldsLoading && _fields.isEmpty)
                    Expanded(child: Center(child: Text('当前设备暂未设置字段')),),

                  if (!_fieldsLoading && _fields.isNotEmpty)
                    DataFieldBar(
                      fields: _fields,
                      selectedFieldKey: _selectedFieldKey,
                      activeColor: Colors.blue,
                      onFieldSelected: _handleFieldSelected,
                    ),
                  SizedBox(height: 16),

                  if (!_fieldsLoading &&
                      _fields.isNotEmpty &&
                      _windowStart != null &&
                      _windowEnd != null)
                    DataTrendChart(
                      line: _firstLine(),
                      lineColor: Colors.blue,
                      visibleStart: _windowStart!,
                      visibleEnd: _windowEnd!,
                      onWindowPan: _handleWindowPan,
                    ),
                ],
              ),
            ),
    );
  }
}
