abstract class AttendanceEvent {}

class CheckInRequested extends AttendanceEvent {
  final int officeLocationId;
  final double checkInLatitude;
  final double checkInLongitude;
  final String? note;

  CheckInRequested({
    required this.officeLocationId,
    required this.checkInLatitude,
    required this.checkInLongitude,
    this.note,
  });
}

class CheckOutRequested extends AttendanceEvent {
  final int officeLocationId;
  final double checkOutLatitude;
  final double checkOutLongitude;

  CheckOutRequested({
    required this.officeLocationId,
    required this.checkOutLatitude,
    required this.checkOutLongitude,
  });
}

class TodayAttendanceRequested extends AttendanceEvent {}

class AttendanceSummaryRequested extends AttendanceEvent {}
