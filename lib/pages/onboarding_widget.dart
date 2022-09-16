import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:parental/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardApp extends StatelessWidget {
  const BoardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: const Color(0xFFFF1DA5))),
      home: const OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showHome', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 16.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: Color(0xffff1da5)),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.only(top: 10),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 100),
      titlePadding: EdgeInsets.only(top: 140),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,

      pages: [
        PageViewModel(
          title: "Track your child's location",
          body: "Parents can check their children's location real-time.",
          image: _buildImage('location.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Blocking web sites and applications",
          body:
              "This app automatically blocks application that is inappropriate for children at ages below 10 and Parents can monitor their children's visited websites wherein they can be able to block them.",
          image: _buildImage('learn.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Screentime",
          body:
              "Parents can set a timer for when will the phone be automatically locked which will be needing codes sent to parents.",
          image: _buildImage('screentime.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Activities history",
          body:
              "Parents can see the history of their children's activities on their mobile phones and how much time they spent on them.",
          image: _buildImage('activitieshistory.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      done: const Text('Get Started',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xffff1da5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
