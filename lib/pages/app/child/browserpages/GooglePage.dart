import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class GoogleBrowserPage extends StatefulWidget {
  const GoogleBrowserPage({Key? key}) : super(key: key);

  @override
  _GoogleBrowserPageState createState() => _GoogleBrowserPageState();
}

class _GoogleBrowserPageState extends State<GoogleBrowserPage>
    with AutomaticKeepAliveClientMixin {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController webcontroller;

  List<String> urls = [];
  int index = 0;

  @override
  bool get wantKeepAlive => true;

  Future<bool> checkIfBlocked(String url) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blockedWebsites')
        .where('url', isEqualTo: 'https://' + url.split("/")[2])
        .get()
        .then((result) {
      if (result.size > 0) {
        return true;
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: SafeArea(
          child: WebView(
            initialUrl: 'https://www.google.com',
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
              heroTag: 'gbackward',
              child: const FaIcon(FontAwesomeIcons.arrowLeft),
              onPressed: () {
                if (webcontroller != null) {
                  webcontroller.goBack();
                }
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'gforward',
              child: const FaIcon(FontAwesomeIcons.arrowRight),
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
