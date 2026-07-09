// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('KostHubApp initialization smoke test',
      (WidgetTester tester) async {
    // KostHubApp yang baru sudah mandiri, tidak perlu lagi disuapi parameter provider
    // dari luar. Kita cukup memanggilnya secara langsung.
    await tester.pumpWidget(const KostHubApp());

    // Memverifikasi bahwa layar loading awal (BootLoader) muncul dengan teks yang sesuai
    expect(find.text('Starting system...'), findsOneWidget);
  });
}
