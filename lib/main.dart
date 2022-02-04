import 'package:flutter/material.dart';
import './widgets/webview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smily",
      theme: ThemeData(
        fontFamily: 'Opensans',
      ),
      home: const SmilyWebview(),
    );
  }
}
