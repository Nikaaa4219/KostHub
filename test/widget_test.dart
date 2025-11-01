// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/providers/saved_provider.dart';
import 'package:flutter_application_2/providers/history_provider.dart';
import 'package:flutter_application_2/providers/notification_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame. Load authProvider before building app.
    final authProvider = await AuthProvider.loadSavedAuth();
    final savedProvider = SavedProvider();
    await savedProvider.loadSaved();
    final historyProvider = HistoryProvider();
    await historyProvider.loadHistory();
    final notificationProvider = NotificationProvider();
    await notificationProvider.loadNotifications();
    await tester.pumpWidget(
      KostHubApp(
        authProvider: authProvider,
        savedProvider: savedProvider,
        historyProvider: historyProvider,
        notificationProvider: notificationProvider,
      ),
    );

    // Verify that KostHub title/text is present on splash/login.
    expect(find.text('KostHub'), findsWidgets);
  });
}
