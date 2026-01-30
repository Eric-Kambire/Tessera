import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TesseraApp extends StatelessWidget {
  const TesseraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tessera',
      theme: AppTheme.light(),
      routerConfig: AppRouter.config,
    );
  }
}
