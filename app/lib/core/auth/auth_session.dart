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
  int? _userId;
  String? _email;
  String? _role;

  AuthStatus get status => _status;

  int? get userId => _userId;
  String? get email => _email;
  String? get role => _role;

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
      final response = await apiClient.get(ApiConstants.me);
      _setUserFromResponse(response.data);
      _setStatus(AuthStatus.authenticated);
    } catch (_) {
      _clearUser();
      await tokenStorage.clearTokens();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  void markAuthenticated() {
    _setStatus(AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
    _clearUser();
    _setStatus(AuthStatus.unauthenticated);
  }

  void _setUserFromResponse(dynamic data) {
    if (data is! Map || data['user'] is! Map) {
      return;
    }

    final user = data['user'] as Map;

    final id = user['id'];
    final email = user['email'];
    final role = user['role'];

    if (id is int) {
      _userId = id;
    }

    if (email is String) {
      _email = email;
    }

    if (role is String) {
      _role = role;
    }
  }

  Future<void> refreshCurrentUser() async {
    final response = await apiClient.get(ApiConstants.me);
    _setUserFromResponse(response.data);
    _setStatus(AuthStatus.authenticated);
  }

  void _clearUser() {
    _userId = null;
    _email = null;
    _role = null;
  }
}
