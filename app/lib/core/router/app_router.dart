import 'package:app/core/auth/auth_session.dart';
import 'package:app/features/admin/presentation/pages/admin_page.dart';
import 'package:app/features/auth/presentation/pages/forbidden_page.dart';
import 'package:app/features/character/presentation/pages/character_select_page.dart';
import 'package:app/features/history/presentation/pages/history_page.dart';
import 'package:app/features/leave/presentation/pages/leave_page.dart';
import 'package:app/features/main/presentation/pages/main_shell_page.dart';
import 'package:app/features/profile/presentation/pages/profile_page.dart';
import 'package:app/features/splash/presentation/pages/splash_page.dart';
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
      final isSelectCharacter = location == '/select_character';
      final isAdminRoute = location.startsWith('/admin');

      final isMainRoute =
          location == '/home' ||
          location == '/history' ||
          location == '/leave' ||
          location == '/profile';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isLogin ? null : '/login';
      }

      if (status == AuthStatus.needsEmployeeProfile) {
        return isSelectCharacter ? null : '/select_character';
      }

      if (status == AuthStatus.authenticated) {
        if (isSplash || isLogin || isSelectCharacter) {
          return '/home';
        }

        if (!isMainRoute && isAdminRoute && authSession.role != 'admin') {
          return '/forbidden';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenPage(),
      ),
      GoRoute(
        path: '/select_character',
        builder: (context, state) => const CharacterSelectPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShellPage(child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '/leave',
            builder: (context, state) => const LeavePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
