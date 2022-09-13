import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'map_show.dart';

class ChildLocationWidget extends StatefulWidget {
  const ChildLocationWidget({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<ChildLocationWidget> createState() => _ChildLocationWidgetState();
}

class _ChildLocationWidgetState extends State<ChildLocationWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.data);
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
              return Scaffold(
                  appBar: AppBar(title: const Text("Tracking Location")),
                  body: FlutterOpenStreetMap(
                    center: LatLong(data["latitude"], data['longitude']),
                    onPicked: (pickedData) {},
                    showZoomButtons: true,
                  ));
            } catch (e) {
              return Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("You are not paired with a child yet"),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Go back"))
                  ],
                )),
              );
            }
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
