import 'package:flutter/material.dart';
import 'package:stm_cqut/Manager/auth_storage.dart';
import '../app_dialog.dart';
import '../Manager/AuthService.dart';
import '../tab_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _passwordShow = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty) {
      AppDialog.showMessage(title: '信息遗漏', message: '请输入用户名');
      return;
    }

    if (password.isEmpty) {
      AppDialog.showMessage(title: '信息遗漏', message: '请输入密码');
      return;
    }

    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (result['code'] != 0) {
        AppDialog.showMessage(
          title: "登录失败",
          message: result['message'] ?? "用户名或密码错误",
        );
        return;
      }

      final data = result['data'];
      final String token = data['token'];
      final String refreshToken = data['refresh_token'];

      await AuthStorage.saveToken(token: token, refreshToken: refreshToken);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TabView()),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();

      AppDialog.showMessage(
        title: "登录失败",
        message: message.isEmpty ? "登录请求失败，请检查网络" : message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey,
        child: Center(
          child: Container(
            width: 320,
            height: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "数据猫监测",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                Text("用户名", style: TextStyle(fontSize: 14, color: Colors.grey)),

                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Colors.grey),

                      SizedBox(width: 8),

                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "请输入用户名",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                Text("密码", style: TextStyle(fontSize: 14, color: Colors.grey)),

                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.password, color: Colors.grey),

                      SizedBox(width: 16),

                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _passwordShow,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "请输入密码",
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordShow = !_passwordShow;
                          });
                        },
                        icon: Icon(
                          _passwordShow
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 42),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text("登录"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
