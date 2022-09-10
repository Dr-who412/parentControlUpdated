import 'package:flutter/material.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebView(
        initialUrl: 'https://www.google.com',
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
        },
        onProgress: (int progress) {
          print('WebView is loading (progress : $progress%)');
        },
        navigationDelegate: (NavigationRequest request) {
          print("the request is $request");
          if (request.url.startsWith('https://www.youtube.com/')) {
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
