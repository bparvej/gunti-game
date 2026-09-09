import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const BanglaGutiApp());
}
