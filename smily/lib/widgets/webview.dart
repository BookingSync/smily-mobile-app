import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SmilyWebview extends StatefulWidget {
  const SmilyWebview({Key? key}) : super(key: key);

  @override
  _SmilyWebviewState createState() => _SmilyWebviewState();
}

class _SmilyWebviewState extends State<SmilyWebview> {
  var webViewLink = "https://www.bookingsync.com/en/users/login?type=smily";
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    if (Platform.localeName.toString().split("_").first == "fr") {
      webViewLink = "https://www.bookingsync.com/fr/users/login?type=smily";
    }
  }

  @override
  Widget build(BuildContext context) {
    WebViewController? controller;
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return WebView(
              initialUrl: webViewLink,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                controller = webViewController;
              },
              onPageStarted: (url) {
                if (url == "https://www.bookingsync.com/fr" ||
                    url == "https://www.bookingsync.com/en") {
                  setState(
                    () {
                      controller!.loadUrl(webViewLink);
                    },
                  );
                }
              },
              userAgent: "SmilyMobileApp/v1.0",
            );
          },
        ),
      ),
    );
  }
}
