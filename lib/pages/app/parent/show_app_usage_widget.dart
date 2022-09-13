import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowAppUsageWidget extends StatefulWidget {
  const ShowAppUsageWidget({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<ShowAppUsageWidget> createState() => _ShowAppUsageWidgetState();
}

class _ShowAppUsageWidgetState extends State<ShowAppUsageWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.data);
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.data['child'])
            .collection('appsUsage')
            .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usersStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData && snapshot.data!.size > 0) {
            try {
              List<QueryDocumentSnapshot<Map<String, dynamic>>> apps =
                  snapshot.data!.docs;
              apps.forEach(
                (element) {
                  print(element.data());
                },
              );
              return Scaffold(
                  appBar: AppBar(title: const Text("App Usage")),
                  body: ListView.builder(
                    itemBuilder: (BuildContext context, int position) {
                      Map<String, dynamic> data = apps[position].data();
                      bool blocked =
                          data['blocked'] == null ? false : data['blocked'];
                      return ListTile(
                        leading: FaIcon(!blocked
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.x),
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.data['child'])
                              .collection('appsUsage')
                              .doc(apps[position].id)
                              .set({'blocked': !blocked},
                                  SetOptions(merge: true)).then((value) {
                            print("updated");
                          });
                        },
                        title: Text(data['appName']),
                        trailing: Text(data['usage']),
                      );
                    },
                    itemCount: apps.length,
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
