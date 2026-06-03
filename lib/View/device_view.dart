import 'package:flutter/material.dart';
import 'package:stm_cqut/app_dialog.dart';
import '../Manager/DeviceService.dart';
import '../Model/device.dart';

class DeviceView extends StatefulWidget {
  final String? selectedDeviceId;
  final void Function(String id, String name) onDeviceSelected;

  const DeviceView({
    super.key,
    required this.selectedDeviceId,
    required this.onDeviceSelected,
  });

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  List<DeviceCard> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 获取设备列表
  Future<void> _loadDeviceCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final devices = await DeviceService.getDeviceCards();

      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });

      AppDialog.showMessage(title: "失败", message: message.isEmpty ? "获取设备列表失败" : message);
    }
  }

  // 选中自动上移顶行
  List<DeviceCard> _dispalyDevices() {
    final devices = List<DeviceCard>.from(_devices);

    if (widget.selectedDeviceId == null) {
      return devices;
    }

    final index = devices.indexWhere(
      (item) => item.deviceId == widget.selectedDeviceId,
    );

    if (index <= 0) {
      return devices;
    }

    final selectDevice = devices.removeAt(index);
    devices.insert(0, selectDevice);
    return devices;
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceCards();
  }

  // 设备状态
  String _statusText(String status) {
    if (status == 'online') {
      return "在线";
    }
    return "离线";
  }

  Color _statusColor(String status) {
    if (status == 'online') {
      return Colors.green;
    }
    return Colors.grey;
  }

  // 时间文本
  String _formatTime(String value) {
    if (value.isEmpty) {
      return '暂无';
    }

    try {
      final dateTime = DateTime.parse(value).toLocal();
      final year = dateTime.year;
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$year-$month-$day【$hour:$minute】';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDevices = _dispalyDevices();
    return Scaffold(
      appBar: AppBar(title: Text("设备列表")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _devices.isEmpty
          ? const Center(child: Text("暂无设备"))
          : RefreshIndicator(
              onRefresh: _loadDeviceCards,
              child: ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: displayDevices.length + 1,
                separatorBuilder: (_, _) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "请选择设备",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  final device = displayDevices[index - 1];
                  return _DeviceRow(device);
                },
              ),
            ),
    );
  }

  // 设备样式行
  Widget _DeviceRow(DeviceCard device) {
    final bool isSelected = device.deviceId == widget.selectedDeviceId;

    return GestureDetector(
      onTap: isSelected
          ? null
          : () {
              AppDialog.show(
                title: device.name,
                message: "确认选择该设备吗？",
                actions: [
                  AppDialogAction(text: "取消"),
                  AppDialogAction(
                    text: "确定",
                    isPrimary: true,
                    onPressed: () async {
                      widget.onDeviceSelected(device.deviceId, device.name);
                    },
                  ),
                ],
              );
            },

      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(255, 64, 153, 255),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name.isEmpty ? "未命名设备" : device.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (device.pendingAlarmCount > 0) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${device.pendingAlarmCount} 条警告待处理',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(device.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(device.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(device.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              device.location.isEmpty ? "暂无" : device.location,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Text(
              "联系人：${device.contactSummary.isEmpty ? "暂无" : device.contactSummary}",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              '最近上报时间：${_formatTime(device.lastDataAt)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 211, 190),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '最近异常',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 6),
                  Text(
                    device.latestAlarm?.message ?? "无",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
