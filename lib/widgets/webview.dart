//This is the webview widget used to display bookingsync website

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
// #enddocregion platform_imports
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../smily_theme.dart';

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

  const SmilyWebView(
      {super.key,
      required this.initialUrl,
      required this.deviceUid,
      required this.firebaseToken,
      required this.notificationsEnabled});

  @override
  SmilyWebViewState createState() => SmilyWebViewState();
}

class SmilyWebViewState extends State<SmilyWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isLoadingError = false;

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
        webViewLink = dotenv.env['URL_LOGIN_FR']!;
      } else {
        webViewLink = dotenv.env['URL_LOGIN_EN']!;
      }
    }

    String version = '2';
    String buildNumber = '1';
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('SmilyMobileApp/v$version.$buildNumber')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {},
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
        onWebResourceError: (error) {
          setState(() {
            _isLoadingError = true;
          });
          _showErrorDialog(controller, Uri.parse(webViewLink));
        },
        onNavigationRequest: (NavigationRequest request) {
          if (!_isLoadingError) {
            bool isExternal =
                externalUrls.any((url) => request.url.startsWith(url));

            if (isExternal) {
              _launchUrl(request.url);

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          } else {
            return NavigationDecision.prevent;
          }
        },
      ))
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

  void _showErrorDialog(WebViewController controller, Uri url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: const SizedBox(
                height: 200,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                          CircleAvatar(
                            radius: 50,
                            child: FaIcon(FontAwesomeIcons.wifi,
                                color: SmilyTheme.defaultIconColor, size: 58),
                          ),
                          SizedBox(height: 6),
                          Text('Looks like you\'re offline',
                              style: TextStyle(
                                color: SmilyTheme.modalTitleColor,
                                fontSize: SmilyTheme.modalTitleSize,
                                fontWeight: SmilyTheme.modalTitleWeight,
                              )),
                          SizedBox(height: 6),
                          Text('Check your internet connection and try again.',
                              style: TextStyle(
                                color: SmilyTheme.modalTextColor,
                                fontSize: SmilyTheme.modalTextSize,
                                fontWeight: SmilyTheme.modalTextWeight,
                              )),
                        ])))),
            actions: <Widget>[
              Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Expanded(
                    flex: 1,
                    child: TextButton(
                        onPressed: () {
                          exit(0);
                        },
                        style: SmilyTheme.buttonDefaultStyle,
                        child: const Text(
                          'Quit app',
                          style: SmilyTheme.buttonDefaultTextStyle,
                        ))),
                const SizedBox(width: 6),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoadingError = false;
                        });
                        controller.loadRequest(url);
                        Navigator.of(context).pop();
                      },
                      style: SmilyTheme.buttonPrimaryStyle,
                      child: const Text(
                        'Try again',
                        style: SmilyTheme.buttonPrimaryTextStyle,
                      ),
                    ))
              ])
            ],
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(SmilyTheme.modalRadius)),
            ),
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            surfaceTintColor: Colors.transparent);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(children: [
        WebViewWidget(controller: _controller),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(),
      ])),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
