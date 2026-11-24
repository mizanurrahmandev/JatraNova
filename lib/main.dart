import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependency injection
  await configureInjection();

  runApp(const MyApp());
}
