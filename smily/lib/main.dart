import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', ''), Locale('fr', '')],
      path: "Assets/Locales",
      fallbackLocale: Locale('en', ''),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Smily',
      theme: ThemeData(
        fontFamily: 'Opensans',
      ),
      home: MyWebView(),
    );
  }
}

class MyWebView extends StatefulWidget {
  const MyWebView({Key? key}) : super(key: key);

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late WebViewController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 2,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'webview_URL'.tr(),
            onWebViewCreated: (controller) {
              this.controller = controller;
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.import_export, size: 32),
          onPressed: () async {
            controller.loadUrl(
                "https://www.bookingsync.com/fr/users/login?type=smily");
          },
        ),
      );
}
