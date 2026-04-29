import 'package:app/core/storage/token_storage.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  final TokenStorage tokenStorage;

  const AuthGate({super.key, required this.tokenStorage});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: tokenStorage.getRefreshToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final refreshToken = snapshot.data;

        if (refreshToken != null && refreshToken.isNotEmpty) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
