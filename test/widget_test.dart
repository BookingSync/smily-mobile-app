// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/mockito.dart';
import 'package:smily/main.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  testWidgets('Message handling', (WidgetTester tester) async {
    const message = RemoteMessage(data: {
      'booking_url': 'https://example.com/booking',
    });
    final appState = MyAppState();

    // Simulate message handling
    appState.handleMessage(message);

    expect(appState.initialUrl, equals('https://example.com/booking'));
  });
}
