import 'package:dio/dio.dart';
import '../Services/api.dart';
import '../Model/user.dart';

class AuthService {
  // 登录
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await Api().dio.post(
        Api.login,
        data: {'username': username, 'password': password},
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '登录失败'));
    }
  }

  // 获取当前登录用户信息
  static Future<User> getCurrentUserInfo() async {
    try {
      final response = await Api().dio.get(Api.userProfile);
      final result = response.data;

      if (result['code'] != 0) {
        throw Exception(Api.resultMessage(result, '获取当前登录用户资料失败'));
      }

      return User.fromJson(result['data']);
    } on DioException catch (e) {
      throw Exception(Api.dioMessage(e, '获取当前登录用户资料失败'));
    }
  }
}
