import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRemoteDatasource({required this.apiClient, required this.tokenStorage});

  Future<void> login({required String email, required String password}) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    debugPrint('Login response: ${response.data}');

    final data = response.data;
    final tokenData = data is Map && data['tokens'] is Map
        ? data['tokens']
        : data is Map && data['data'] is Map
        ? data['data']
        : data;

    if (tokenData is! Map) {
      throw FormatException('Invalid login response: ${response.data}');
    }

    final accessToken = tokenData['accessToken'] ?? tokenData['access_token'];
    final refreshToken =
        tokenData['refreshToken'] ?? tokenData['refresh_token'];

    if (accessToken is! String || refreshToken is! String) {
      throw FormatException('Missing login tokens: ${response.data}');
    }

    await tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await apiClient.post(
          ApiConstants.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } finally {
      await tokenStorage.clearTokens();
    }
  }
}
