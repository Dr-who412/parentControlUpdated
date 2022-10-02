import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppsListScreen extends StatefulWidget {
  const AppsListScreen({Key? key}) : super(key: key);

  @override
  AppsListScreenState createState() => AppsListScreenState();
}

class AppsListScreenState extends State<AppsListScreen> {
  bool _showSystemApps = false;
  bool _onlyLaunchableApps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed applications'),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                    value: 'system_apps', child: Text('Toggle system apps')),
                const PopupMenuItem<String>(
                  value: 'launchable_apps',
                  child: Text('Toggle launchable apps only'),
                )
              ];
            },
            onSelected: (String key) {
              if (key == 'system_apps') {
                setState(() {
                  _showSystemApps = !_showSystemApps;
                });
              }
              if (key == 'launchable_apps') {
                setState(() {
                  _onlyLaunchableApps = !_onlyLaunchableApps;
                });
              }
            },
          )
        ],
      ),
      body: _AppsListScreenContent(
          includeSystemApps: _showSystemApps,
          onlyAppsWithLaunchIntent: _onlyLaunchableApps,
          key: GlobalKey()),
    );
  }
}

class _AppsListScreenContent extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;

  const _AppsListScreenContent(
      {Key? key,
      this.includeSystemApps = false,
      this.onlyAppsWithLaunchIntent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Application>>(
      future: DeviceApps.getInstalledApplications(
          includeAppIcons: true, onlyAppsWithLaunchIntent: true),
      builder: (BuildContext context, AsyncSnapshot<List<Application>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          List<Application> apps = data.data!;
          return Scrollbar(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (BuildContext context, int position) {
                  Application app = apps[position];
                  return GestureDetector(
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('appsUsage')
                          .doc(app.packageName)
                          .get()
                          .then((result) {
                        if (result.exists) {
                          bool blocked = result.data()!['blocked'] ?? false;
                          if (blocked) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("This app is blocked"),
                              duration: Duration(milliseconds: 2000),
                            ));
                          } else {
                            app.openApp();
                          }
                        } else {
                          app.openApp();
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.memory(
                            (app as ApplicationWithIcon).icon,
                            width: 32,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Flexible(
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  strutStyle: StrutStyle(fontSize: 12.0),
                                  text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      text: app.appName))),
                          // Text(
                          //   app.appName,
                          //   textAlign: TextAlign.center,
                          // ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: apps.length,
              ),
            ),
            // child: ListView.builder(
            //     itemBuilder: (BuildContext context, int position) {
            //       Application app = apps[position];
            //       return Column(
            //         children: <Widget>[
            //           ListTile(
            //             leading: app is ApplicationWithIcon
            //                 ? CircleAvatar(
            //                     backgroundImage: MemoryImage(app.icon),
            //                     backgroundColor: Colors.white,
            //                   )
            //                 : null,
            //             onTap: () {
            //               FirebaseFirestore.instance
            //                   .collection('users')
            //                   .doc(FirebaseAuth.instance.currentUser!.uid)
            //                   .collection('appsUsage')
            //                   .doc(app.packageName)
            //                   .get()
            //                   .then((result) {
            //                 if (result.exists) {
            //                   bool blocked = result.data()!['blocked'] ?? false;
            //                   if (blocked) {
            //                     ScaffoldMessenger.of(context)
            //                         .showSnackBar(const SnackBar(
            //                       content: Text("This app is blocked"),
            //                       duration: Duration(milliseconds: 2000),
            //                     ));
            //                   } else {
            //                     app.openApp();
            //                   }
            //                 } else {
            //                   app.openApp();
            //                 }
            //               });
            //             },
            //             title: Text(app.appName),
            //             subtitle: Text('Version: ${app.versionName}\n'),
            //           ),
            //           const Divider(
            //             height: 1.0,
            //           )
            //         ],
            //       );
            //     },
            //     itemCount: apps.length),
          );
        }
      },
    );
  }

  void onAppClicked(BuildContext context, Application app) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(app.appName),
            actions: <Widget>[
              _AppButtonAction(
                label: 'Open app',
                onPressed: () {
                  app.openApp();
                },
              ),
              _AppButtonAction(
                label: 'Open app settings',
                onPressed: () => app.openSettingsScreen(),
              ),
              _AppButtonAction(
                label: 'Uninstall app',
                onPressed: () async => app.uninstallApp(),
              ),
            ],
          );
        });
  }
}

class _AppButtonAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AppButtonAction({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed?.call();
        Navigator.of(context).maybePop();
      },
      child: Text(label),
    );
  }
}
