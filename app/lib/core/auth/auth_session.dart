import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthSession extends ChangeNotifier {
  final TokenStorage tokenStorage;
  final ApiClient apiClient;

  AuthSession({required this.tokenStorage, required this.apiClient});

  AuthStatus _status = AuthStatus.unknown;

  AuthStatus get status => _status;

  void _setStatus(AuthStatus value) {
    if (_status == value) {
      return;
    }

    _status = value;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    try {
      await apiClient.get(ApiConstants.me);
      _setStatus(AuthStatus.authenticated);
    } catch (_) {
      await tokenStorage.clearTokens();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  void markAuthenticated() {
    _setStatus(AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
    _setStatus(AuthStatus.unauthenticated);
  }
}
