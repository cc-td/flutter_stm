import 'package:flutter/material.dart';
import 'package:stm_cqut/app_dialog.dart';
import '../Manager/auth_storage.dart';
import './launch_view.dart';
import '../Manager/AuthService.dart';
import '../Model/user.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  User? _user;
  bool _isloading = true;
  String? _errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadingUserInfo();
  }

    // 获取信息
  Future<void> _loadingUserInfo() async {
    setState(() {
      _isloading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.getCurrentUserInfo();

      setState(() {
        _user = user;
        _isloading = false;
      });
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _errorMessage = message;
        _isloading = false;
      });

      AppDialog.showMessage(
        title: "失败",
        message: message.isEmpty ? "获取用户信息失败" : message,
      );
    }
  }

  // 退出登录
  Future<void> _handleLogOut(BuildContext context) async {
    AppDialog.show(
      title: "登出",
      message: "确定要登出吗？",
      actions: [
        AppDialogAction(text: "取消"),
        AppDialogAction(
          text: "确定",
          isPrimary: true,
          onPressed: () async {
            await AuthStorage.clearToken();
            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LaunchView()),
            );
          },
        ),
      ],
    );
  }



  // 信息行样式
  Widget _UserInfoRow(String title, String dec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),

          Expanded(
            child: Text(
              dec.isEmpty ? "未填写" : dec,
              style: TextStyle(
                fontSize: 15,
                color: dec.isEmpty
                    ? Colors.grey
                    : const Color.fromARGB(255, 27, 131, 205),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("设置")),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "个人资料",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _UserInfoRow("用户名", _user?.username ?? ''),
                    _UserInfoRow("邮箱", _user?.email ?? ''),
                    _UserInfoRow("手机号", _user?.phone ?? ''),
                    _UserInfoRow("Bark Key", _user?.barkDeviceKey ?? ''),
                    _UserInfoRow("企业微信Hook", _user?.wecomWebhook ?? ''),
                    _UserInfoRow("级别", _user?.role ?? ''),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _handleLogOut(context),
            child: Text("登出", style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
