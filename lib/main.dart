import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EagleSmartBusinessApp());
}

class EagleSmartBusinessApp extends StatelessWidget {
  const EagleSmartBusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eagle Smart Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
