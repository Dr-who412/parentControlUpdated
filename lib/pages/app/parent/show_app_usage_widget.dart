import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                                  SetOptions(merge: true)).then((value) {});
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
          } else if (snapshot.hasData && snapshot.data!.size <= 0) {
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
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
