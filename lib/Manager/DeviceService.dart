import 'package:dio/dio.dart';
import '../Services/api.dart';
import '../Model/device.dart';
import '../Model/data.dart';
import '../Model/alarms.dart';

class DeviceService {
  // 获取字段列表
  static Future<List<DeviceFieldOption>> getDeviceFieldOptions(
    String deviceId,
  ) async {
    try {
      final response = await Api().dio.get(
        Api.deviceFieldOptions,
        queryParameters: {'device_id': deviceId},
      );
      final result = response.data;

      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '获取字段列表失败'));
      }
      final List list = result['data']['list'] ?? [];
      return list
          .map(
            (item) => DeviceFieldOption.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '获取字段列表失败'));
    }
  }

  //曲线
  static Future<TimeSeriesResponse> getTimeSeries({
    required String deviceId,
    required String field,
    required DateTime start,
    required DateTime end,
    String interval = '1m',
  }) async {
    try {
      final response = await Api().dio.get(
        Api.dataTimeseries,
        queryParameters: {
          'device_id': deviceId,
          'field': field,
          'start': start.toUtc().toIso8601String(),
          'end': end.toUtc().toIso8601String(),
          'interval': interval,
        },
      );
      final result = response.data;
      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '获取趋势数据失败'));
      }

      return TimeSeriesResponse.fromJson(
        Map<String, dynamic>.from(result['data'] as Map),
      );
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '获取趋势数据失败'));
    }
  }

  // 设备卡片
  static Future<List<DeviceCard>> getDeviceCards() async {
    try {
      final response = await Api().dio.get(Api.deviceCards);
      final result = response.data;

      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '获取设备列表失败'));
      }

      final List list = result['data']['list'] ?? [];
      return list.map((item) => DeviceCard.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '获取设备列表失败'));
    }
  }

  // 警报获取
  static Future<AlarmPage> getAlarmRecords({
    required String deviceId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await Api().dio.get(
        Api.alarmRecords,
        queryParameters: {
          'device_id': deviceId,
          'page': page,
          'page_size': pageSize,
          'compact': 1,
        },
      );

      final result = response.data;

      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '获取报警列表失败'));
      }

      return AlarmPage.fromJson(
        Map<String, dynamic>.from(result['data'] as Map),
      );
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '获取报警列表失败'));
    }
  }

  // 处理警报
  static Future<void> handleAlarmRecord({
    required int alarmId,
    String status = 'handle',
    String remark = '',
  }) async {
    try {
      final response = await Api().dio.put(
        '${Api.alarmRecords}/$alarmId/handle',
        data: {'status': status, 'remark': remark},
      );

      final result = response.data;
      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '处理报警失败'));
      }
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '处理报警失败'));
    }
  }
}
