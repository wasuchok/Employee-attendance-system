import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app/features/auth/presentation/bloc/auth_event.dart';
import 'package:app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDatasource authRemoteDatasource;

  AuthBloc({required this.authRemoteDatasource}) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await authRemoteDatasource.login(
        email: event.email,
        password: event.password,
      );

      emit(AuthSuccess());
    } on DioException catch (e) {
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');

      emit(AuthFailure(message: e.response?.data['message'] ?? 'Login failed'));
    } catch (e, stackTrace) {
      debugPrint('Unknown error: $e');
      debugPrint('$stackTrace');

      emit(
        AuthFailure(
          message: "An error occurred during login. Please try again.",
        ),
      );
    }
  }
}
