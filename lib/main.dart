import 'package:flutter/material.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  app.load();
  runApp(const BanglaGutiApp());
}
