import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../parent/map_show.dart';

class ParentLocationWidget extends StatefulWidget {
  const ParentLocationWidget({Key? key}) : super(key: key);

  @override
  State<ParentLocationWidget> createState() => _ParentLocationWidgetState();
}

class _ParentLocationWidgetState extends State<ParentLocationWidget> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
        stream: usersStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            try {
              Map<String, dynamic> data =
                  snapshot.data?.data() as Map<String, dynamic>;
              return Scaffold(
                  appBar: AppBar(title: const Text("Tracking Location")),
                  body: FlutterOpenStreetMap(
                    center: LatLong(
                        data["parentlatitude"], data['parentlongitude']),
                    onPicked: (pickedData) {},
                    showZoomButtons: true,
                  ));
            } catch (e) {
              return Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You are not paired with a child yet"),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Go back"))
                  ],
                )),
              );
            }
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
