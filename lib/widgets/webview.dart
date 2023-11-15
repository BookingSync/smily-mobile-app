//This is the webview widget used to display bookingsync website

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports
import 'package:url_launcher/url_launcher.dart';

class SmilyWebView extends StatefulWidget {
  const SmilyWebView({Key? key}) : super(key: key);

  @override
  _SmilyWebViewState createState() => _SmilyWebViewState();
}

class _SmilyWebViewState extends State<SmilyWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    late final String webViewLink;

    if (Platform.localeName.toString().split("_").first == "fr") {
      webViewLink = "https://www.bookingsync.com/fr/users/login?type=smily";
    } else {
      webViewLink = "https://www.bookingsync.com/en/users/login?type=smily";
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('SmilyMobileApp/v1.0')
      ..setNavigationDelegate(
        NavigationDelegate(
          // onPageStarted: (String url) {
          //   if (url == "https://www.bookingsync.com/fr" ||
          //       url == "https://www.bookingsync.com/en") {
          //     setState(
          //           () {
          //         controller!.loadUrl(webViewLink);
          //       },
          //     );
          //   }
          // },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://bookingsync-core-production')) {
              _launchUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(webViewLink));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
