//This is the webview widget used to display bookingsync website

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
    //Checks for device's language congiguration then change webview's URL accordingly
    if (Platform.localeName.toString().split("_").first == "fr") {
      webViewLink = "https://www.bookingsync.com/fr/users/login?type=smily";
    }
  }

  @override
  Widget build(BuildContext context) {
    WebViewController? controller;
    return Scaffold(
      body: WebView(
        initialUrl: webViewLink,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
        //Checks every single redirection.
        onPageStarted: (url) {
          //Logging out from the website triggers loading the main page.
          //This condition redirects user straight to login page
          if (url == "https://www.bookingsync.com/fr" ||
              url == "https://www.bookingsync.com/en") {
            setState(
              () {
                controller!.loadUrl(webViewLink);
              },
            );
          }
        },
        //Initialises useragent as requested
        userAgent: "SmilyMobileApp/v1.0",
      ),
    );
  }
}
