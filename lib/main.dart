import 'dart:ui';
import 'package:flutter/material.dart';
import 'app/tessera_app.dart';
import 'app/router/app_router.dart';
import 'injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _showGlobalError(details.exceptionAsString(), details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _showGlobalError(error.toString(), stack);
    return true;
  };

  runApp(const TesseraApp());
}

void _showGlobalError(String message, StackTrace? stack) {
  final context = AppRouter.rootKey.currentState?.overlay?.context;
  if (context == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: SingleChildScrollView(
            child: SelectableText(
              [message, if (stack != null) '\n\n$stack'].join(''),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  });
}
