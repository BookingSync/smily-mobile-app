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

List<String> externalUrls = [
  'https://bookingsync-core-production',
  'https://bookingsync-core-staging',
  'https://changelog.bookingsync.com',
  'https://changelog.smily.com',
];

class SmilyWebView extends StatefulWidget {
  final String initialUrl;
  final String deviceUid;
  final String? firebaseToken;
  final bool notificationsEnabled;

  const SmilyWebView({
    super.key,
    required this.initialUrl,
    required this.deviceUid,
    required this.firebaseToken,
    required this.notificationsEnabled
  });

  @override
  SmilyWebViewState createState() => SmilyWebViewState();
}

class SmilyWebViewState extends State<SmilyWebView> {
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

    String webViewLink = widget.initialUrl;

    if (webViewLink.isEmpty) {
      if (Platform.localeName.toString().split('_').first == 'fr') {
        webViewLink = 'https://phoenix.bookingsync.com/fr/users/login?type=smily';
      } else {
        webViewLink = 'https://phoenix.bookingsync.com/en/users/login?type=smily';
      }
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('SmilyMobileApp/v1.0')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            final String jsCode = """
              window.mobileDeviceUid = "${widget.deviceUid}";
              window.mobileFirebaseToken = "${widget.firebaseToken ?? ''}";
              window.notificationsEnabled = ${widget.notificationsEnabled ? 1 : 0};
            """;
            await controller.runJavaScript(jsCode);
          },
          onNavigationRequest: (NavigationRequest request) {
            bool isExternal =
                externalUrls.any((url) => request.url.startsWith(url));

            if (isExternal) {
              _launchUrl(request.url);

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        )
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..addJavaScriptChannel(
        'messageHandler',
        onMessageReceived: (JavaScriptMessage javaScriptMessage) {
          print('SMILY: ${javaScriptMessage.message}');
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
  void didUpdateWidget(SmilyWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl) {
      _controller.loadRequest(Uri.parse(widget.initialUrl));
    }
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
