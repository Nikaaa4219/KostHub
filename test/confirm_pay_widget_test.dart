// Auto-generated per user prompt — manual review required
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/confirm_pay_screen.dart';
import 'package:flutter_application_2/models/room.dart';
import 'package:flutter_application_2/widgets/date_picker_bottom_sheet.dart';
import 'package:flutter_application_2/widgets/guest_picker_bottom_sheet.dart';
import 'package:flutter_application_2/providers/history_provider.dart';
import 'package:flutter_application_2/providers/notification_provider.dart';
import 'package:flutter_application_2/providers/saved_provider.dart';
import 'package:flutter_application_2/services/payment_service.dart';

void main() {
  testWidgets('ConfirmPay flow success (skeleton)', (tester) async {
    // Arrange: create sample room and selections
    final room = Room(
      id: 't1',
      name: 'Test Room',
      location: 'Test City',
      price: 100.0,
      rating: 4.5,
      reviews: 10,
      assetImage: 'assets/images/room1.jpg',
    );
    final months = MonthsSelection(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      monthsCount: 1,
    );
    final guests = GuestSelection(adults: 1, children: 0, infants: 0);

    // ensure PaymentService returns verified
    PaymentService.forceVerifyResult = true;

    final history = HistoryProvider();
    await history.loadHistory();
    final notif = NotificationProvider();
    await notif.loadNotifications();
    final saved = SavedProvider();
    await saved.loadSaved();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: history),
          ChangeNotifierProvider.value(value: notif),
          ChangeNotifierProvider.value(value: saved),
        ],
        child: MaterialApp(
          home: ConfirmPayScreen(room: room, months: months, guests: guests),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The skeleton test verifies the Pay Now button exists; interactions with dialogs
    // require more detailed widget bindings and are left as an exercise for full
    // integration tests.
    expect(find.text('Pay Now'), findsOneWidget);
  });
}
