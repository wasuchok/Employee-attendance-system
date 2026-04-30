import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class CharacterRemoteDatasource {
  final ApiClient apiClient;

  CharacterRemoteDatasource({required this.apiClient});

  Future<void> ensureEmployeeProfile({
    required String employeeCode,
    required String fullName,
    required String position,
    required String phone,
    required String avatarUrl,
  }) async {
    try {
      await apiClient.get(ApiConstants.me);
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        rethrow;
      }
    }

    await createEmployeeProfile(
      employeeCode: employeeCode,
      fullName: fullName,
      position: position,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  Future<void> createEmployeeProfile({
    required String employeeCode,
    required String fullName,
    required String position,
    required String phone,
    required String avatarUrl,
  }) async {
    await apiClient.post(
      ApiConstants.createEmployeeProfile,
      data: {
        'employee_code': employeeCode,
        'full_name': fullName,
        'position': position,
        'phone': phone,
        'avatar_url': avatarUrl,
        'department_id': null,
      },
    );
  }
}
