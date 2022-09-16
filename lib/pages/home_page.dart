import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in.dart';
import 'app/child_app.dart';
import 'app/parent_app.dart';
import 'configuration_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: const Color(0xFFFF1DA5))),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return const UserPage();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong..."),
            );
          } else {
            return const SignInPage(
              title: "Parental Controls",
            );
          }
        },
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final user = FirebaseAuth.instance.currentUser;

  bool configuring = false;
  bool configured = false;

  void configureData() {
    setState(() {
      configuring = true;
    });
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ConfigurationPage()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context, listen: false);
    String id = user!.uid;
    Future<bool> isConfigured = provider.isConfigured(id);

    isConfigured.then((value) {
      if (!value && !configuring) {
        configureData();
      } else {
        if (!configured) {
          setState(() {
            configured = true;
          });
        }
      }
    });

    final Stream<DocumentSnapshot> usersStream =
        FirebaseFirestore.instance.collection('users').doc(id).snapshots();

    if (configured) {
      return StreamBuilder<DocumentSnapshot>(
        stream: usersStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if ((snapshot.connectionState == ConnectionState.active) &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            try {
              Map<String, dynamic> data =
                  snapshot.data?.data() as Map<String, dynamic>;
              if (data['identity'] == 'parent') {
                return ParentApp(
                  data: data,
                  id: id,
                );
              } else {
                return ChildApp(
                  data: data,
                  doc: snapshot.data,
                );
              }
            } catch (e) {
              return const Text("Something went wrong");
            }
          } else {
            return const Text("Something went wrong");
          }
        },
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
