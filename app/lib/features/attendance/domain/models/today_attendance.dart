class TodayAttendance {
  final int id;
  final int employeeId;
  final int officeLocationId;
  final String officeLocationName;
  final DateTime attendanceDate;
  final DateTime checkInTime;
  final double checkInLatitude;
  final double checkInLongitude;
  final double distanceMeters;
  final String note;

  const TodayAttendance({
    required this.id,
    required this.employeeId,
    required this.officeLocationId,
    required this.officeLocationName,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInLatitude,
    required this.checkInLongitude,
    required this.distanceMeters,
    required this.note,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      id: _parseInt(json['id']),
      employeeId: _parseInt(json['employee_id']),
      officeLocationId: _parseInt(json['office_location_id']),
      officeLocationName: json['office_location_name']?.toString() ?? '',
      attendanceDate: _parseDateTime(json['attendance_date']),
      checkInTime: _parseDateTime(json['check_in_time']),
      checkInLatitude: _parseDouble(json['check_in_latitude']),
      checkInLongitude: _parseDouble(json['check_in_longitude']),
      distanceMeters: _parseDouble(json['distance_meters']),
      note: json['note']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }

    return DateTime.now();
  }
}
