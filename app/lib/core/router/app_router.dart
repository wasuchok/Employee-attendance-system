import 'package:app/core/auth/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';

GoRouter createAppRouter({required AuthSession authSession}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authSession,

    redirect: (context, state) {
      final status = authSession.status;
      final location = state.matchedLocation;

      final isSplash = location == '/splash';
      final isLogin = location == '/login';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isLogin ? null : '/login';
      }

      if (status == AuthStatus.authenticated) {
        if (isSplash || isLogin) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );
}
