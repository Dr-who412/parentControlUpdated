import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_street_map/flutter_open_street_map.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:location/location.dart';
import '../../provider/sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class ChildApp extends StatefulWidget {
  const ChildApp({Key? key, required this.data, required this.doc})
      : super(key: key);
  final Map<String, dynamic> data;
  final DocumentSnapshot<Object?>? doc;

  @override
  State<ChildApp> createState() => _ChildAppState();
}

class _ChildAppState extends State<ChildApp> {
  List<Widget> toReturn = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => sendLocation());
  }

  void generateQrCode() {
    setState(() {
      toReturn.add(
        QrImage(data: FirebaseAuth.instance.currentUser!.uid),
      );
    });
  }

  void sendLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final doc =
        FirebaseFirestore.instance.collection('users').doc(widget.doc?.id);

    doc.get().then((data) {
      if (data.exists) {
        if (!data.data()!.isEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.doc?.id)
              .set({
            'latitude': _locationData.latitude,
            'longitude': _locationData.longitude
          }, SetOptions(merge: true));
        }
      }
    });
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
              const SizedBox(
                height: 30,
              ),
              Text(
                "Welcome ${widget.data['name']}(${widget.data['age']} yrs old)",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: generateQrCode, child: Text("Pair to parent")),
              ...toReturn,
            ],
          ),
        ));
  }
}

class MapViewer extends StatefulWidget {
  const MapViewer({Key? key}) : super(key: key);

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          ),
      body: FlutterOpenStreetMap(
          center: LatLong(5, 10),
          onPicked: (pickedData) {
            print(pickedData.latLong.latitude);
            print(pickedData.latLong.longitude);
            print(pickedData.address);
          }),
    );
  }
}
