import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:parental/pages/app/parent/child_browser_history_widget.dart';
import 'package:parental/pages/app/parent/child_location_map_widget.dart';
import 'package:parental/pages/app/parent/show_app_usage_widget.dart';
import 'package:provider/provider.dart';
import '../../provider/sign_in.dart';
import '../configuration_page.dart';

class ParentApp extends StatefulWidget {
  const ParentApp({Key? key, required this.data, required this.id})
      : super(key: key);
  final Map<String, dynamic> data;
  final String id;

  @override
  State<ParentApp> createState() => _ParentAppState();
}

class _ParentAppState extends State<ParentApp> {
  String qrID = '';
  Map<String, dynamic> childData = {};

  Future scanQr() async {
    try {
      await BarcodeScanner.scan(
              options: const ScanOptions(restrictFormat: [BarcodeFormat.qr]))
          .then((result) {
        pairChild(result.rawContent);
      });
    } catch (e) {
      return;
    }
  }

  void pairChild(String id) {
    if (id.isEmpty) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((data) {
      if (data.exists) {
        if (data.data()!.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.id)
              .set({'child': id}, SetOptions(merge: true));
        }
      }
    });
  }

  Timer? timer;
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => sendLocation());
  }

  void sendLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.data['child'])
        .set({
      'parentlatitude': locationData.latitude,
      'parentlongitude': locationData.longitude
    }, SetOptions(merge: true));
  }

  Widget showChild(BuildContext context) {
    final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.data['child'])
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
        stream: usersStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Center(
                        child: Text(
                      "Child Data",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    )),
                    Row(
                      children: [
                        const Icon(Icons.face),
                        const Text(
                          "|",
                          style: TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(data['name'])
                      ],
                    ),
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.hashtag),
                        const SizedBox(
                          width: 3,
                        ),
                        const Text(
                          "|",
                          style: TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(data['age'].toString())
                      ],
                    ),
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.phone),
                        const Text(
                          "|",
                          style: TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(data['phoneNumber'])
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && !snapshot.data!.exists) {
            return FractionallySizedBox(
              widthFactor: 1,
              child: SizedBox(
                height: 300,
                child: Card(
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pair with your child first"),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: scanQr, child: const Text('Pair'))
                    ],
                  )),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<bool> handleBackPress() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => handleBackPress(),
      child: Scaffold(
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
              icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                // Card(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const FaIcon(
                //               FontAwesomeIcons.addressBook,
                //               size: 25,
                //             ),
                //             Text(
                //               "   ${widget.data['name']}",
                //               style: const TextStyle(fontSize: 20),
                //             ),
                //           ],
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const FaIcon(
                //               FontAwesomeIcons.hashtag,
                //               size: 25,
                //             ),
                //             Text(
                //               "   ${widget.data['age']}",
                //               style: const TextStyle(fontSize: 20),
                //             ),
                //           ],
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const FaIcon(
                //               FontAwesomeIcons.phone,
                //               size: 20,
                //             ),
                //             Text(
                //               "   ${widget.data['phoneNumber']}",
                //               style: const TextStyle(fontSize: 20),
                //             ),
                //           ],
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const FaIcon(
                //               FontAwesomeIcons.person,
                //               size: 25,
                //             ),
                //             Text(
                //               "    ${widget.data['identity']}",
                //               style: const TextStyle(fontSize: 20),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.face,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "|",
                          style: TextStyle(fontSize: 40),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.data['name'],
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.hashtag,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "|",
                              style: TextStyle(fontSize: 30),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.data['age'].toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.phone,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            const Text(
                              "|",
                              style: TextStyle(fontSize: 30),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.data['phoneNumber'].toString(),
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
                            const SizedBox(
                              width: 11,
                            ),
                            const Text(
                              "|",
                              style: TextStyle(fontSize: 30),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.data['identity'].toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                showChild(context),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(
            size: 30,
          ),
          visible: true,
          backgroundColor: const Color(0xFFFF1da5),
          curve: Curves.bounceIn,
          spacing: 10,
          spaceBetweenChildren: 20,
          children: [
            SpeedDialChild(
              backgroundColor: const Color(0xFFFF1da5),
              child: const FaIcon(
                FontAwesomeIcons.qrcode,
                color: Colors.white,
              ),
              onTap: scanQr,
              label: 'Pair to Child',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Color(0xFF067BC2)),
            ),
            SpeedDialChild(
              child: const FaIcon(
                FontAwesomeIcons.mapPin,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ChildLocationWidget(data: widget.data)));
              },
              backgroundColor: const Color(0xFFFF1da5),
              label: 'Child Location',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Color(0xFF067BC2)),
            ),
            SpeedDialChild(
              child: const FaIcon(
                FontAwesomeIcons.android,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowAppUsageWidget(data: widget.data)));
              },
              backgroundColor: const Color(0xFFFF1da5),
              label: 'Child App Usage',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Color(0xFF067BC2)),
            ),
            SpeedDialChild(
              child: const FaIcon(
                FontAwesomeIcons.clockRotateLeft,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ChildBrowserHistoryWidget(data: widget.data)));
              },
              backgroundColor: const Color(0xFFFF1da5),
              label: 'Child Browser History',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Color(0xFF067BC2)),
            ),
            SpeedDialChild(
              child: const FaIcon(
                FontAwesomeIcons.pen,
                color: Colors.white,
              ),
              backgroundColor: const Color(0xffff1da5),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigurationPage()));
              },
              label: 'Edit Profile',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xff067bc2),
                  fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
