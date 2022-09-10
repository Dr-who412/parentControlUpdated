import 'package:flutter/material.dart';

class AppTileWidget {
  const AppTileWidget(
      {required this.appname, required this.icon, required this.usage});
  final String appname;
  final CircleAvatar icon;
  final String usage;
}
