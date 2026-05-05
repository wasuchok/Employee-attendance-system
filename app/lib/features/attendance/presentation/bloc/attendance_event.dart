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

class TodayAttendanceRequested extends AttendanceEvent {}
