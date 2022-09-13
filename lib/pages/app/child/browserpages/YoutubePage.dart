import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class YoutubeBrowserPage extends StatefulWidget {
  const YoutubeBrowserPage({Key? key}) : super(key: key);

  @override
  _YoutubeBrowserPageState createState() => _YoutubeBrowserPageState();
}

class _YoutubeBrowserPageState extends State<YoutubeBrowserPage>
    with AutomaticKeepAliveClientMixin {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController webcontroller;

  List<String> urls = [];
  int index = 0;

  Future<bool> checkIfBlocked(String url) async {
    print('https://' + url.split("/")[2]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockedWebsites')
        .where('url', isEqualTo: 'https://' + url.split("/")[2])
        .get()
        .then((result) {
      print(result.size);
      if (result.size > 0) {
        return true;
      } else {
        return false;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: WebView(
            initialUrl: 'https://www.youtube.com/',
            onWebViewCreated: (WebViewController controller) {
              _controller.complete(controller);
              setState(() {
                webcontroller = controller;
              });
            },
            onProgress: (int progress) {},
            navigationDelegate: (NavigationRequest request) {
              return checkIfBlocked(request.url).then((value) {
                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("This website is blocked"),
                    duration: Duration(milliseconds: 2000),
                  ));
                  return NavigationDecision.prevent;
                } else {
                  return NavigationDecision.navigate;
                }
              });
            },
            onPageStarted: (String url) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('history')
                  .doc()
                  .set({
                'url': url,
                'date': Timestamp.fromDate(DateTime.now()),
                'website': 'https://' + url.split("/")[2],
              }).then((value) {
                print('history saved');
              });
              setState(() {
                urls.add(url);
                index++;
              });
            },
            onPageFinished: (String url) {},
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'ybackward',
              child: FaIcon(FontAwesomeIcons.arrowLeft),
              onPressed: () {
                if (webcontroller != null) {
                  webcontroller.goBack();
                }
              },
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'yforward',
              child: FaIcon(FontAwesomeIcons.arrowRight),
              onPressed: () {
                if (webcontroller != null) {
                  webcontroller.goForward();
                }
              },
            ),
          ],
        ));
  }
}
