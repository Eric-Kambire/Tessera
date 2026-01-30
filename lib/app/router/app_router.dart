import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/solver/presentation/pages/solver_page.dart';

class AppRouter {
  static final rootKey = GlobalKey<NavigatorState>();
  static final GoRouter config = GoRouter(
    navigatorKey: rootKey,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const SolverPage(),
      ),
    ],
  );
}
