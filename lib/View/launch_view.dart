import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/api.dart';
import '../Manager/auth_storage.dart';
import '../Manager/AuthService.dart';
import 'login_view.dart';
import '../tab_view.dart';

class LaunchView extends StatefulWidget {
  const LaunchView({super.key});

  @override
  State<LaunchView> createState() => _LaunchViewState();
}

class _LaunchViewState extends State<LaunchView> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthStorage.getToken();
    final re = await AuthStorage.getRefreshToken();
    if (!mounted) return;

    print(token);
    print("dddddd\n");
    print(re);

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
      return;
    }

    try {
      await AuthService.getCurrentUserInfo();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TabView()),
      );
    } catch (e) {
      final refreshSatus = await Api().refreshTokenSafely();

      if (refreshSatus) {
        if (!mounted) return;

        try {
          await AuthService.getCurrentUserInfo();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TabView()),
          );
          return;
        } catch (e) {
          await AuthStorage.clearToken();

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        }
      } else {
        await AuthStorage.clearToken();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
