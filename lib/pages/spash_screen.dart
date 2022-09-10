import 'package:flutter/material.dart';
import 'package:parental/pages/home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/vectorpaint.svg';
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetName,
            width: 500,
            height: 500,
          ),
          Container(
            width: 250,
            child: Text(
              "e-Monitoring mobile application for children’s actvities towards their actions on their mobile phones",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "In City College of Calamba",
            textAlign: TextAlign.center,
          )
        ],
      ),
    )));
  }
}
