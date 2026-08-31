// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasToken = prefs.getString('access_token') != null;

  runApp(FitLifeApp(initialRoute: hasToken ? AppRoutes.home : AppRoutes.auth));
}

class FitLifeApp extends StatelessWidget {
  final String initialRoute;

  const FitLifeApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
