import 'package:flutter/material.dart';
import 'package:workorders/pages/login_page.dart';

import '../controllers/session_controller.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async {
        bool isLogged = await SessionController.isLogged();
        if (isLogged) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          child: Center(
            child: Image.asset('assets/images/logo.png', width: 300.0),
          ),
          onWillPop: () async => false),
    );
  }
}
