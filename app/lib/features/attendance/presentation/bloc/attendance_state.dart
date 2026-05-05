import 'package:app/features/attendance/domain/models/today_attendance.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class TodayAttendanceLoading extends AttendanceState {}

class CheckInLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {}

class AttendanceFailure extends AttendanceState {
  final String message;

  AttendanceFailure({required this.message});
}

class TodayAttendanceLoaded extends AttendanceState {
  final TodayAttendance? attendance;

  TodayAttendanceLoaded({required this.attendance});
}
