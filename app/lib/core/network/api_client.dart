import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final TokenStorage tokenStorage;

  late final Dio dio;
  late final Dio refreshDio;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final isRefreshRequest =
              requestOptions.path == ApiConstants.refreshToken;

          if (statusCode == 401 && !isRefreshRequest) {
            try {
              final newAccessToken = await _refreshToken();

              if (newAccessToken == null) {
                await tokenStorage.clearTokens();
                return handler.reject(error);
              }

              requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              final response = await refreshDio.fetch(requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException) {
                return handler.reject(retryError);
              }

              await tokenStorage.clearTokens();
              return handler.reject(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await refreshDio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data;
    final tokenData = data is Map ? data['tokens'] : null;

    if (tokenData is! Map) {
      return null;
    }

    final accessToken = tokenData['access_token'];
    final newRefreshToken = tokenData['refresh_token'];

    if (accessToken == null || newRefreshToken == null) {
      return null;
    }

    await tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );

    return accessToken;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
