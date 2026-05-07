import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/attendance/domain/models/today_attendance.dart';

class AttendanceRemoteDatasource {
  final ApiClient apiClient;

  AttendanceRemoteDatasource({required this.apiClient});

  Future<void> checkIn({
    required int officeLocationId,
    required double checkInLatitude,
    required double checkInLongitude,
    String? note,
  }) async {
    await apiClient.post(
      ApiConstants.attendanceCheckIn,
      data: {
        'office_location_id': officeLocationId,
        'check_in_latitude': checkInLatitude,
        'check_in_longitude': checkInLongitude,
        'note': note ?? '',
      },
    );
  }

  Future<void> checkOut({
    required int officeLocationId,
    required double checkOutLatitude,
    required double checkOutLongitude,
  }) async {
    await apiClient.post(ApiConstants.attendanceCheckOut, data : {
      'office_location_id': officeLocationId,
      'check_out_latitude': checkOutLatitude,
      'check_out_longitude': checkOutLongitude,
    });
  }

  Future<TodayAttendance?> getTodayAttendance() async {
    final response = await apiClient.get(ApiConstants.attendanceToday);

    final data = response.data;
    final attendanceData = data is Map ? data['data'] : null;

    if (attendanceData == null) {
      return null;
    }

    if (attendanceData is! Map) {
      throw FormatException(
        'Invalid today attendance response: ${response.data}',
      );
    }

    return TodayAttendance.fromJson(Map<String, dynamic>.from(attendanceData));
  }
}
