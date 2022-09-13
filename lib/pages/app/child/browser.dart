import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parental/pages/app/child/browserpages/GooglePage.dart';
import 'package:parental/pages/app/child/browserpages/YoutubePage.dart';

class ChildBrowser extends StatefulWidget {
  const ChildBrowser({Key? key}) : super(key: key);

  @override
  State<ChildBrowser> createState() => _ChildBrowserState();
}

class _ChildBrowserState extends State<ChildBrowser>
    with TickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browser")),
      bottomNavigationBar: Container(
        color: Color(0xffff1da5),
        child: TabBar(
          controller: tabController,
          tabs: const <Tab>[
            Tab(
              icon: Icon(FontAwesomeIcons.google),
              text: "Google",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.youtube),
              text: "Youtube",
            )
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [GoogleBrowserPage(), YoutubeBrowserPage()],
      ),
    );
  }
}
