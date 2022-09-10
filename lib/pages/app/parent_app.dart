import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sign_in.dart';

class ParentApp extends StatefulWidget {
  const ParentApp({Key? key, required this.data, required this.id})
      : super(key: key);
  final Map<String, dynamic> data;
  final String id;

  @override
  State<ParentApp> createState() => _ParentAppState();
}

class _ParentAppState extends State<ParentApp> {
  String QrId = '';

  Future scanQr() async {
    try {
      ScanResult qrResult = await BarcodeScanner.scan();
      setState(() {
        QrId = qrResult.rawContent;
        print(QrId);
        pairChild(QrId);
      });
    } catch (e) {
      print(e);
    }
  }

  void pairChild(String id) {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((data) {
      if (data.exists) {
        if (!data.data()!.isEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.id)
              .set({'child': id}, SetOptions(merge: true));
        }
      }
    });
  }

  Widget showChild() {
    try {
      final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.data['child'])
          .snapshots();
      return StreamBuilder<DocumentSnapshot>(
          stream: usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              try {
                Map<String, dynamic> data =
                    snapshot.data?.data() as Map<String, dynamic>;
                return Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Child's name: ${data['name']}",
                        style: const TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                );
              } catch (e) {
                return const Text("Something went wrong");
              }
            } else {
              return const Text("Pair with your child first");
            }
          });
    } catch (e) {
      return const Text("Pair with your child first");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Parental Controls"),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {
                  print("logging out");
                  final provider =
                      Provider.of<SignInProvider>(context, listen: false);
                  provider.logout();
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent),
                ))
          ],
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                "Welcome ${widget.data['name']}(${widget.data['age']} yrs old)",
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(onPressed: scanQr, child: Text("Pair to child")),
              showChild(),
            ],
          ),
        ));
  }
}
