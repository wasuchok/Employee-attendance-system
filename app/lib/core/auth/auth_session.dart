import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus {
  unknown,
  authenticated,
  needsEmployeeProfile,
  unauthenticated,
}

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _clearUser();
        _setStatus(AuthStatus.needsEmployeeProfile);
        return;
      }

      _clearUser();
      await tokenStorage.clearTokens();
      _setStatus(AuthStatus.unauthenticated);
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
    if (data is! Map) {
      return;
    }

    final userData = data['data'] ?? data['user'];

    if (userData is! Map) {
      return;
    }

    final id = userData['user_id'] ?? userData['id'];
    final email = userData['email'];
    final role = userData['role'];

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
    try {
      final response = await apiClient.get(ApiConstants.me);
      _setUserFromResponse(response.data);
      _setStatus(AuthStatus.authenticated);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _clearUser();
        _setStatus(AuthStatus.needsEmployeeProfile);
        return;
      }

      rethrow;
    }
  }

  void _clearUser() {
    _userId = null;
    _email = null;
    _role = null;
  }
}
