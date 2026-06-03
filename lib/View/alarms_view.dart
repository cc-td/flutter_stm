import 'package:flutter/material.dart';
import 'package:stm_cqut/Manager/DeviceService.dart';
import 'package:stm_cqut/app_dialog.dart';
import '../Model/alarms.dart';

class AlarmsView extends StatefulWidget {
  final String? selectedDeviceId;
  final String? selectedDeviceName;
  final bool isActive;

  const AlarmsView({
    super.key,
    required this.selectedDeviceId,
    required this.selectedDeviceName,
    required this.isActive,
  });

  @override
  State<AlarmsView> createState() => _AlarmViewSata();
}

class _AlarmViewSata extends State<AlarmsView> {
  static int _pageSize = 20;

  AlarmPage? _alarmPage;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _preparePage();
  }

  @override
  void didUpdateWidget(covariant AlarmsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool becameActive = widget.isActive && !oldWidget.isActive;
    final bool deviceChanged =
        widget.selectedDeviceId != oldWidget.selectedDeviceId;

    if (becameActive || (widget.isActive && deviceChanged)) {
      _preparePage();
    }
  }

  Future<void> _preparePage() async {
    final bool hasDevice =
        widget.selectedDeviceId != null && widget.selectedDeviceId!.isNotEmpty;

    if (!hasDevice) {
      if (!mounted) return;

      setState(() {
        _alarmPage = null;
        _errorMessage = null;
        _isLoading = false;
        _currentPage = 1;
      });
      return;
    }

    setState(() {
      _currentPage = 1;
    });

    await _loadAlarms();
  }

  // 获取记录
  Future<void> _loadAlarms() async {
    final bool hasDevice =
        widget.selectedDeviceId != null && widget.selectedDeviceId!.isNotEmpty;
    if (!hasDevice) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DeviceService.getAlarmRecords(
        deviceId: widget.selectedDeviceId!,
        page: _currentPage,
      );
      if (!mounted) return;

      setState(() {
        _alarmPage = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final m = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _alarmPage = null;
        _errorMessage = m;
        _isLoading = false;
      });

      AppDialog.showMessage(title: "失败", message: m.isEmpty ? '获取警报列表是失败' : m);
    }
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

  // 警告样式
  Color _levelColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  String _levelText(String level) {
    switch (level) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return '低';
    }
  }

  // 处理状态
  Color _statusColor(String status) {
    if (status == 'handled') {
      return Colors.green;
    }
    return Colors.orange;
  }

  String _statusText(String status) {
    if (status == 'handled') {
      return '已处理';
    }
    return '未处理';
  }

  // 总页数
  int get _totalPages {
    final total = _alarmPage?.total ?? 0;
    final pages = (total + _pageSize - 1) ~/ _pageSize;
    return pages < 1 ? 1 : pages;
  }

  // 切页
  Future<void> _changePage(int nextPage) async {
    if (_isLoading) return;
    if (nextPage < 1) return;
    if (nextPage > _totalPages) return;
    if (nextPage == _currentPage) return;

    setState(() {
      _currentPage = nextPage;
    });
    await _loadAlarms();
  }

  // 处理警报
  Future<void> _showHandleSheet(AlarmRecord alarm) async {
    if (alarm.status == 'handled') return;
    if (!alarm.canHandle) {
      AppDialog.showMessage(title: "提示", message: "该设备的警报您无权处理");
      return;
    }

    String remarkText = '';
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.displayCategory.isEmpty
                          ? '处理警报'
                          : alarm.displayCategory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      alarm.displaySummary.isEmpty
                          ? '暂无摘要'
                          : alarm.displaySummary,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      maxLines: 4,
                      onChanged: (v) {
                        remarkText = v;
                      },
                      decoration: InputDecoration(
                        hintText: '请输入处理备注（可留空）',
                        filled: true,
                        fillColor: Color.fromARGB(255, 183, 181, 181),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() {
                                  isSaving = true;
                                });

                                try {
                                  await DeviceService.handleAlarmRecord(
                                    alarmId: alarm.id,
                                    remark: remarkText.trim(),
                                  );

                                  if (!mounted) return;

                                  Navigator.of(sheetContext).pop();
                                  await AppDialog.showMessage(
                                    title: '成功',
                                    message: '警报已处理',
                                  );

                                  await _loadAlarms();
                                } catch (e) {
                                  final message = e
                                      .toString()
                                      .replaceFirst('Exception: ', '')
                                      .trim();

                                  await AppDialog.showMessage(
                                    title: '失败',
                                    message: message.isEmpty
                                        ? '处理警报失败'
                                        : message,
                                  );

                                  setSheetState(() {
                                    isSaving = false;
                                  });
                                }
                              },
                        child: Text('保存并处理'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDevice =
        widget.selectedDeviceId != null && widget.selectedDeviceId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedDeviceName ?? '警报页')),
      body: !hasDevice
          ? Center(child: Text('请在设备页面选择一个设备'))
          : _isLoading
          ? Center(child: CircularProgressIndicator())
          : _alarmPage == null || _alarmPage!.list.isEmpty
          ? Center(child: Text("当前设备暂无记录"))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _currentPage > 1
                              ? () => _changePage(_currentPage - 1)
                              : null,
                          icon: Icon(Icons.chevron_left),
                        ),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '第$_currentPage / $_totalPages 页',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '共 ${_alarmPage?.total ?? 0} 条',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: _currentPage < _totalPages
                              ? () => _changePage(_currentPage + 1)
                              : null,
                          icon: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: _alarmPage!.list.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alarm = _alarmPage!.list[index];
                      return GestureDetector(
                        onTap: () => _showHandleSheet(alarm),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(18, 11, 11, 11),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          alarm.displayCategory.isEmpty
                                              ? '警报'
                                              : alarm.displayCategory,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _levelText(alarm.level),
                                          style: TextStyle(
                                            color: _levelColor(alarm.level),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    _statusText(alarm.status),
                                    style: TextStyle(
                                      color: _statusColor(alarm.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                alarm.displaySummary.isEmpty
                                    ? '暂无摘要'
                                    : alarm.displaySummary,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(alarm.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
