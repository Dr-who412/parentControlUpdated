import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parental/pages/app/usage_statistics_widget.dart';
import 'package:parental/provider/sign_in.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late String _email, _password;
  final auth = FirebaseAuth.instance;

  Future<void> _showMyDialog(String message) async {
    if (message == "") return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('I Understand'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 90,
            ),
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 100,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(14, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.elliptical(100, 100))),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Email",
                    labelText: 'Email',
                    border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(14, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.elliptical(100, 100))),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Password",
                    labelText: 'Password',
                    border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: Text("Forgot Password?"))
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<SignInProvider>(context, listen: false);
                      String message =
                          await provider.emailLogin(_email, _password);
                      _showMyDialog(message);
                    },
                    child: const Text("Login"),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                  ),
                ),
              ],
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const SizedBox(
            //       width: 20,
            //     ),
            //     ElevatedButton(
            //         onPressed: () async {
            //           final provider =
            //               Provider.of<SignInProvider>(context, listen: false);
            //           String message =
            //               await provider.emailSignUp(_email, _password);
            //           _showMyDialog(message);
            //         },
            //         child: const Text("Sign Up")),
            //   ],
            // ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    ));
  }
}
