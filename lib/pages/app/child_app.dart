import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_street_map/flutter_open_street_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parental/pages/app/child/browser.dart';
import 'package:parental/pages/app/child/launcher.dart';
import 'package:parental/pages/app/qrcode_widget.dart';
import 'package:parental/pages/app/usage_statistics_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:location/location.dart';
import '../../provider/sign_in.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  Widget? qrCode;

  Timer? timer;
  UsageStatisticsWidget usages = UsageStatisticsWidget();
  bool canPlay = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => sendLocation());
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are not allowed to play yet'),
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

  void generateQrCode() {
    setState(() {
      toReturn.add(
        QrImage(data: FirebaseAuth.instance.currentUser!.uid),
      );
      qrCode = QrImage(data: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void sendLocation() async {
    if (mounted) {
      setState(() {
        canPlay = usages.getDuration() > 0;
        print("can the child play? ${usages.getDuration()}");
        print(canPlay);
      });
    }
    Location location = Location();

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
        if (data.data()!.isNotEmpty) {
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

  void toLauncher() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AppsListScreen()));
  }

  void toBrowser() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChildBrowser()));
  }

  void toQrCode() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => QRCodeWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parental Controls"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final provider =
                  Provider.of<SignInProvider>(context, listen: false);
              provider.logout();
            },
            icon: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            color: Colors.amber[500],
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              height: 150,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.addressBook,
                            size: 25,
                          ),
                          Text(
                            "   ${widget.data['name']}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.hashtag,
                            size: 25,
                          ),
                          Text(
                            "   ${widget.data['age']}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.phone,
                            size: 20,
                          ),
                          Text(
                            "   ${widget.data['phoneNumber']}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.person,
                            size: 25,
                          ),
                          Text(
                            "    ${widget.data['identity']}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: usages,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme:
            IconThemeData(size: 30, color: Color.fromARGB(255, 249, 170, 51)),
        backgroundColor: Colors.blueGrey.shade600,
        visible: true,
        curve: Curves.bounceIn,
        spacing: 10,
        spaceBetweenChildren: 20,
        children: [
          SpeedDialChild(
              child: FaIcon(
                FontAwesomeIcons.android,
                color: Colors.blueGrey.shade600,
              ),
              backgroundColor: Colors.amber[600],
              onTap: toLauncher,
              label: 'App Launcher',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.blueGrey.shade600,
              visible: canPlay),
          SpeedDialChild(
              child: FaIcon(
                FontAwesomeIcons.globe,
                color: Colors.blueGrey.shade600,
              ),
              backgroundColor: Colors.amber[600],
              onTap: toBrowser,
              label: 'Open Browser',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.blueGrey.shade600),
          SpeedDialChild(
              child: FaIcon(
                FontAwesomeIcons.qrcode,
                color: Colors.blueGrey.shade600,
              ),
              backgroundColor: Colors.amber[600],
              onTap: toQrCode,
              label: 'Pair to Parent',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.blueGrey.shade600),
        ],
      ),
    );
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
