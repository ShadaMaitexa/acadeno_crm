import 'package:acadeno_crm/features/auth/logout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows logout confirmation dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showLogoutConfirmationDialog(context),
                child: const Text('Open logout'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open logout'));
    await tester.pumpAndSettle();

    expect(find.text('Logout?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to log out of your session?'),
      findsOneWidget,
    );
  });
}
