import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_tile_widget.dart';

class UsageStatisticsWidget extends StatefulWidget {
  UsageStatisticsWidget({Key? key}) : super(key: key);
  final _UsageStatisticsWidgetState wid = _UsageStatisticsWidgetState();

  int getDuration() {
    return wid.getDuration();
  }

  @override
  State<UsageStatisticsWidget> createState() => wid;
}

class _UsageStatisticsWidgetState extends State<UsageStatisticsWidget> {
  List<Widget> icons = [];
  List<AppTileWidget> usageApps = [];
  Timer? timer;
  bool loading = false;
  DateTime endDate = DateTime.now();
  Duration screenTime = const Duration(hours: 0);

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => getApps());
  }

  int getDuration() {
    return screenTime.inMinutes;
  }

  void getApps() async {
    if (loading) {
      return;
    }
    if (!mounted) return;
    setState(() {
      endDate = DateTime.now();
    });
    Duration st = const Duration(hours: 20);
    DateTime startDate = endDate.subtract(const Duration(hours: 12));
    await AppUsage.getAppUsage(startDate, endDate).then((infoList) async {
      if (!mounted) return;
      await DeviceApps.getInstalledApplications(
              onlyAppsWithLaunchIntent: true, includeAppIcons: true)
          .then((apps) {
        if (!mounted) return;
        setState(() {
          loading = true;
        });
        usageApps = [];
        for (var app in apps) {
          for (var info in infoList) {
            if (app.packageName == info.packageName) {
              if (app is ApplicationWithIcon) {
                CircleAvatar avatar = CircleAvatar(
                  backgroundImage: MemoryImage(app.icon),
                  backgroundColor: Colors.white,
                );
                AppTileWidget appTile = AppTileWidget(
                    appname: app.appName,
                    icon: avatar,
                    usage: info.usage.toString().split(".")[0]);
                usageApps.add(appTile);
                st = Duration(minutes: st.inMinutes - info.usage.inMinutes);

                final usageDoc = {
                  'appName': app.appName,
                  'usage': info.usage.toString().split(".")[0],
                };
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('appsUsage')
                    .doc(app.packageName)
                    .set(usageDoc);
              }
            }
          }
        }

        usageApps.sort(((a, b) {
          return b.usage.compareTo(a.usage);
        }));
        if (!mounted) return;
        setState(() {
          loading = false;
          screenTime = st;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (usageApps.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text("This will take some time"),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0x00),
          elevation: 0,
          title: Text(
            "Duration Left: ${screenTime.inMinutes} minutes",
            style: TextStyle(color: Color(0xff067bc2)),
          ),
        ),
        body: Scrollbar(
          child: ListView.builder(
              itemBuilder: (BuildContext context, int position) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: usageApps[position].icon,
                      title: Text(usageApps[position].appname),
                      trailing: Text(usageApps[position].usage),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              },
              itemCount: usageApps.length),
        ),
      );
    }
  }
}
