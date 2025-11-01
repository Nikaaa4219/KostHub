import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/edit_profile_screen.dart';
import 'package:flutter_application_2/services/user_service.dart'
    as user_service;
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/models/user.dart';

void main() {
  testWidgets(
    'Update button calls updateProfileFn and pops with updated user',
    (WidgetTester tester) async {
      User? calledWith;
      user_service.updateProfileFn = (User u) async {
        calledWith = u;
        return u.copyWith(name: 'Updated Name');
      };

      final hostKey = GlobalKey<HostState>();

      final authProvider = await AuthProvider.loadSavedAuth();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: authProvider,
            child: Host(key: hostKey),
          ),
        ),
      );

      // Open the EditProfileScreen
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Tap the Update button
      await tester.tap(find.text('Update Profile'));
      await tester.pumpAndSettle();

      expect(
        calledWith,
        isNotNull,
        reason: 'updateProfileFn should be called with a User',
      );

      final hostState = hostKey.currentState;
      expect(hostState, isNotNull);
      expect(
        hostState!.lastResult,
        isNotNull,
        reason: 'Host should receive the popped result',
      );

      // The stub update returns a User with updated name
      final result = hostState.lastResult;
      expect(result, isA<User>());
      expect((result as User).name, 'Updated Name');
    },
  );

  testWidgets('Gender selection changes to Female when tapped', (
    WidgetTester tester,
  ) async {
    user_service.updateProfileFn = (User u) async => u;

    final authProvider = await AuthProvider.loadSavedAuth();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: authProvider,
          child: const EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final femaleFinder = find.text('Female');
    expect(femaleFinder, findsOneWidget);
    await tester.tap(femaleFinder);
    await tester.pumpAndSettle();

    final radio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Female'),
    );
    expect(radio.groupValue, 'Female');
  });
}

class Host extends StatefulWidget {
  const Host({super.key});

  @override
  HostState createState() => HostState();
}

class HostState extends State<Host> {
  dynamic lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Open Edit'),
          onPressed: () async {
            final res = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            setState(() => lastResult = res);
          },
        ),
      ),
    );
  }
}
