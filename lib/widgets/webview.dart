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
import 'package:package_info_plus/package_info_plus.dart';

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
  bool _isLoading = true;

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

    String version = '2';
    String buildNumber = '1';
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });

    print('UserAgent');
    print('SmilyMobileApp/v$version.$buildNumber');

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('SmilyMobileApp/v$version.$buildNumber')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
         onPageFinished: (String url) async {
            final String jsCode = """
              window.mobileDeviceUid = "${widget.deviceUid}";
              window.mobileFirebaseToken = "${widget.firebaseToken ?? ''}";
              window.notificationsEnabled = ${widget.notificationsEnabled ? 1 : 0};
            """;
            await controller.runJavaScript(jsCode);
            setState(() {
              _isLoading = false;
            });
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
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            _isLoading ? const Center(child: CircularProgressIndicator()) : Container(),
          ]
        )
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
