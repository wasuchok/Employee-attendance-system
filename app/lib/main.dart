import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const EmployeeAttendanceApp());
}

class EmployeeAttendanceApp extends StatelessWidget {
  const EmployeeAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authRemoteDatasource = AuthRemoteDatasource(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: tokenStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRemoteDatasource: authRemoteDatasource),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthGate(tokenStorage: tokenStorage),
        ),
      ),
    );
  }
}
