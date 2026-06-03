import 'dart:convert';
import 'package:dio/dio.dart';
import '../Manager/auth_storage.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = '';
  static const String login = '/auth/login';
  static const String userProfile = '/user/profile';
  static const String deviceCards = '/devices/cards';
  static const String deviceFieldOptions = '/options/device-fields';
  static const String dataTimeseries = '/data/timeseries';
  static const String alarmRecords = '/alarms/records';
  static const String refresh = '/auth/refresh';

  static final Api _instance = Api._internal();
  factory Api() => _instance;

  late Dio dio;
  Future<bool>? _refreshingTokenFuture;

  Api._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final bool hasRetried = request.extra['authRetried'] == true;
          final bool isAuthRequest =
              request.path == login || request.path == refresh;

          if (error.response?.statusCode == 401 &&
              !hasRetried &&
              !isAuthRequest) {
            final refreshed = await refreshTokenSafely();

            if (refreshed) {
              final response = await _retryRequest(error.requestOptions);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }
  //刷新token
  Future<bool> _refreshTokenRequest() async {
    final refreshToken = await AuthStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      final result = jsonDecode(response.body);
      if (result['code'] != 0) return false;

      final data = result['data'];
      final String newToken = data['token'];
      final String newRefreshToken = data['refresh_token'];

      await AuthStorage.saveToken(
        token: newToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // 判断是否需要刷新token
  Future<bool> refreshTokenSafely() {
    final runningTask = _refreshingTokenFuture;
    if (runningTask != null) return runningTask;

    final future = _refreshTokenRequest();
    _refreshingTokenFuture = future;

    future.whenComplete(() {
      _refreshingTokenFuture = null;
    });

    return future;
  }

  // 重新发送请求
  Future<Response<dynamic>> _retryRequest(RequestOptions re) async {
    final token = await AuthStorage.getToken();

    final headers = Map<String, dynamic>.from(re.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final extra = Map<String, dynamic>.from(re.extra);
    extra['authRetried'] = true;

    return dio.request<dynamic>(
      re.path,
      data: re.data,
      queryParameters: re.queryParameters,
      options: Options(
        method: re.method,
        headers: headers,
        extra: extra,
        contentType: re.contentType,
        responseType: re.responseType,
        receiveTimeout: re.receiveTimeout,
      ),
    );
  }

  // 处理异常文案
  static String dioMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString() ?? '';
      if (message.isNotEmpty) return message;
    }
    if (data is String && data.isNotEmpty) return data;

    if (error.message != null && error.message!.isNotEmpty)
      return error.message!;

    return fallback;
  }

  static String resultMessage(dynamic result, String fallback) {
    if (result is Map) {
      final message = result['message']?.toString() ?? '';
      if (message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}
