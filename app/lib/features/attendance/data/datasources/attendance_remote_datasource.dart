import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';

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
        'check_in_longtitude': checkInLongitude,
        'note': note ?? '',
      },
    );
  }
}
