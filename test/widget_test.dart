import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bangla_guti/core/di/service_locator.dart';
import 'package:bangla_guti/presentation/app.dart';

void main() {
  testWidgets('App boots and renders game screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initServiceLocator();
    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}