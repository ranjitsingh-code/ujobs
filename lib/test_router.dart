import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  final navKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: navKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              try {
                navKey.currentContext!.go('/locked');
                debugPrint('Success');
              } catch (e) {
                debugPrint('Error: $e');
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: '/locked',
        builder: (_, _) => const Scaffold(),
      )
    ],
  );
  runApp(MaterialApp.router(routerConfig: router));
}
