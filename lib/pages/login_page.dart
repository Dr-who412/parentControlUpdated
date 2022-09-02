import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            children: [
              const SizedBox(
                height: 80,
              ),
              const Text(
                "Welcome to Parental Controls",
                style: TextStyle(fontSize: 35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: "Email"),
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Password", labelText: 'Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        final provider =
                            Provider.of<SignInProvider>(context, listen: false);
                        String message =
                            await provider.emailLogin(_email, _password);
                        _showMyDialog(message);
                      },
                      child: const Text("Login")),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final provider =
                            Provider.of<SignInProvider>(context, listen: false);
                        String message =
                            await provider.emailSignUp(_email, _password);
                        _showMyDialog(message);
                      },
                      child: const Text("Sign Up")),
                ],
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ));
  }
}
