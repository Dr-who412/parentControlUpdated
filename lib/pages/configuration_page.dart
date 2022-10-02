import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sign_in.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

enum Identity { parent, child }

class _ConfigurationPageState extends State<ConfigurationPage> {
  final user = FirebaseAuth.instance.currentUser;

  String _name = "";
  int _age = 1;
  String _phoneNumber = "";

  Identity? _identity = Identity.child;

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

  void setData() {}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuring Data"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                decoration:
                    const InputDecoration(hintText: "Name", labelText: 'Name'),
                onChanged: ((value) {
                  setState(() {
                    _name = value.toString();
                  });
                }),
              ),
              TextFormField(
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: "Age", labelText: 'Age'),
                  onChanged: ((value) {
                    setState(() {
                      try {
                        _age = int.parse(value.toString());
                      } catch (e) {
                        _age = 0;
                      }
                    });
                  })),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: "Phone Number", labelText: 'Phone Number'),
                  onChanged: ((value) {
                    setState(() {
                      _phoneNumber = value.toString();
                    });
                  })),
              ListTile(
                title: const Text('Parent'),
                leading: Radio<Identity>(
                  value: Identity.parent,
                  groupValue: _identity,
                  onChanged: (Identity? value) {
                    setState(() {
                      _identity = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Child'),
                leading: Radio<Identity>(
                  value: Identity.child,
                  groupValue: _identity,
                  onChanged: (Identity? value) {
                    setState(() {
                      _identity = value;
                    });
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_name == "") {
                      _showMyDialog('Please enter your name');
                      return;
                    }
                    if (_identity == Identity.child) {
                      if (_age > 10) {
                        _showMyDialog("Must be 10 years old or below");
                        return;
                      }
                    }
                    if (_age == "") {
                      _showMyDialog("Please enter your age");
                      return;
                    }
                    if (_phoneNumber.length != 11) {
                      _showMyDialog("Please enter your phone number correctly");
                      return;
                    }
                    final data = {
                      'name': _name,
                      'age': _age,
                      'phoneNumber': _phoneNumber,
                      'identity':
                          _identity == Identity.child ? "child" : "parent"
                    };
                    print(data);

                    provider.configureUserData(data, user!.uid);
                    Navigator.pop(context);
                  },
                  child: const Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
