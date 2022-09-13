import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChildBrowserHistoryWidget extends StatefulWidget {
  const ChildBrowserHistoryWidget({Key? key, required this.data})
      : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<ChildBrowserHistoryWidget> createState() =>
      _ChildBrowserHistoryWidgetState();
}

class _ChildBrowserHistoryWidgetState extends State<ChildBrowserHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.data['child'])
            .collection('history')
            .orderBy('date')
            .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usersStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData && snapshot.data!.size > 0) {
            try {
              List<QueryDocumentSnapshot<Map<String, dynamic>>> apps =
                  snapshot.data!.docs;
              return Scaffold(
                  appBar: AppBar(title: const Text("Browser History")),
                  body: ListView.builder(
                    itemBuilder: (BuildContext context, int position) {
                      Map<String, dynamic> data = apps[position].data();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: data['url']));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text("Copied to clipboard"),
                                      duration: Duration(milliseconds: 500),
                                    ));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['website'],
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        data['date']
                                            .toDate()
                                            .toString()
                                            .split(".")[0],
                                        overflow: TextOverflow.ellipsis,
                                        textWidthBasis: TextWidthBasis.parent,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.data['child'])
                                        .collection('blockedWebsites')
                                        .doc()
                                        .set({'url': data['website']}).then(
                                            (value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("Website Blocked"),
                                        duration: Duration(milliseconds: 1000),
                                      ));
                                    });
                                  },
                                  icon: Icon(
                                    Icons.block,
                                  ),
                                )
                              ]),
                        ),
                      );
                    },
                    itemCount: apps.length,
                  ));
            } catch (e) {
              print(e);
              return const Text("Something went wrong");
            }
          } else if (snapshot.hasData && snapshot.data!.size <= 0) {
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
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
