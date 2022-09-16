import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parental/pages/spash_screen.dart';
import 'package:parental/provider/sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  runApp(MyApp(
    showHome: showHome,
  ));
}

class MyApp extends StatelessWidget {
  final bool showHome;
  const MyApp({Key? key, required this.showHome}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => SignInProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(
          showHome: showHome,
        ),
      ));
}
