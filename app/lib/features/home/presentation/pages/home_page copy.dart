import 'package:app/core/auth/auth_session.dart';
import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String _result = 'ยังไม่ได้เรียก API';

  Future<void> _callProtectedApi() async {
    setState(() {
      _isLoading = true;
      _result = 'กำลังเรียก /api/me ...';
    });

    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(ApiConstants.me);

      setState(() {
        _result = 'สำเร็จ: ${response.data}';
      });
    } on DioException catch (e) {
      setState(() {
        _result =
            'ล้มเหลว (${e.response?.statusCode ?? '-'}) ${e.response?.data ?? e.message}';
      });
    } catch (e) {
      setState(() {
        _result = 'ล้มเหลว: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authRemoteDatasource = context.read<AuthRemoteDatasource>();
      final authSession = context.read<AuthSession>();

      await authRemoteDatasource.logout();
      await authSession.logout();

      if (mounted) {
        context.go('/login');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Protected API Test',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _callProtectedApi,
                child: Text(_isLoading ? 'Loading...' : 'Call /api/me'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go('/admin');
                },
                child: const Text('Go Admin'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/select_character');
                },
                child: const Text('Select Character'),
              ),
              const SizedBox(height: 16),
              Text(_result, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isLoggingOut ? null : _logout,
                child: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
