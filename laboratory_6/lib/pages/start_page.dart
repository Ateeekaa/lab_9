import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_form_page.dart';
import 'package:laboratory_6/pages/main_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAuth = prefs.getBool('isAuthenticated') ?? false;
    
    // Если пользователь не авторизован, направляем на экран регистрации
    if (isAuth) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => RegisterFormPage(onRegistered: (_) {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
