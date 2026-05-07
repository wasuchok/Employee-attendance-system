import 'package:app/core/auth/auth_session.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/character/data/datasources/character_remote_datasource.dart';
import 'package:app/features/character/presentation/bloc/character_bloc.dart';
import 'package:app/features/office_location/data/datasources/office_location_remote_datasource.dart';
import 'package:app/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const EmployeeAttendanceApp());
}

class EmployeeAttendanceApp extends StatefulWidget {
  const EmployeeAttendanceApp({super.key});

  @override
  State<EmployeeAttendanceApp> createState() => _EmployeeAttendanceAppState();
}

class _EmployeeAttendanceAppState extends State<EmployeeAttendanceApp> {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthSession authSession;
  late final AuthRemoteDatasource authRemoteDatasource;
  late final GoRouter appRouter;

  @override
  void initState() {
    super.initState();

    tokenStorage = TokenStorage();
    apiClient = ApiClient(tokenStorage: tokenStorage);

    authSession = AuthSession(tokenStorage: tokenStorage, apiClient: apiClient);

    authRemoteDatasource = AuthRemoteDatasource(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    appRouter = createAppRouter(authSession: authSession);

    authSession.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider.value(value: authRemoteDatasource),
        Provider(
          create: (context) =>
              CharacterRemoteDatasource(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) =>
              AttendanceRemoteDatasource(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => OfficeLocationRemoteDatasource(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        Provider(create: (context) => WeatherRemoteDatasource()),
      ],

      child: ChangeNotifierProvider.value(
        value: authSession,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  AuthBloc(authRemoteDatasource: authRemoteDatasource),
            ),
            BlocProvider(
              create: (context) => CharacterBloc(
                characterRemoteDatasource: context
                    .read<CharacterRemoteDatasource>(),
              ),
            ),
            BlocProvider(
              create: (context) => AttendanceBloc(
                attendanceRemoteDatasource: context
                    .read<AttendanceRemoteDatasource>(),
              ),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: GoogleFonts.inter().fontFamily,
              textTheme: GoogleFonts.interTextTheme(),
            ),
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }
}
