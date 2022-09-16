import 'package:flutter/material.dart';
import 'package:parental/pages/home_page.dart';
import 'package:parental/pages/onboarding_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.showHome}) : super(key: key);
  final bool showHome;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToHome());
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1), () {});
    _moveToHome();
  }

  _moveToHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                widget.showHome ? const HomePage() : const BoardApp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/kidami.png',
            width: 500,
            height: 500,
          ),
          const SizedBox(
            width: 250,
            child: Text(
              "e-Monitoring mobile application for children’s actvities towards their actions on their mobile phones",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "In City College of Calamba",
            textAlign: TextAlign.center,
          )
        ],
      ),
    )));
  }
}
