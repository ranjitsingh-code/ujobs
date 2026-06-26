import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  final navKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: navKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              try {
                navKey.currentContext!.go('/locked');
                print('Success');
              } catch (e) {
                print('Error: $e');
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: '/locked',
        builder: (_, __) => const Scaffold(),
      )
    ],
  );
  runApp(MaterialApp.router(routerConfig: router));
}
