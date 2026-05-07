import 'package:app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRemoteDatasource attendanceRemoteDatasource;

  AttendanceBloc({required this.attendanceRemoteDatasource})
    : super(AttendanceInitial()) {
    on<TodayAttendanceRequested>(_onTodayAttendanceRequested);
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
  }

  Future<void> _onCheckIn(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(CheckInLoading());

    try {
      await attendanceRemoteDatasource.checkIn(
        officeLocationId: event.officeLocationId,
        checkInLatitude: event.checkInLatitude,
        checkInLongitude: event.checkInLongitude,
        note: event.note,
      );

      emit(AttendanceSuccess());
    } on DioException catch (e) {
      emit(
        AttendanceFailure(message: _dioMessage(e, fallback: 'Check-in failed')),
      );
    } catch (_) {
      emit(AttendanceFailure(message: 'An error occurred during check-in'));
    }
  }

  Future<void> _onCheckOut(CheckOutRequested event, Emitter<AttendanceState> emit,) async {
    emit(CheckOutLoading());

    try {
      await attendanceRemoteDatasource.checkOut(
              officeLocationId: event.officeLocationId,
      checkOutLatitude: event.checkOutLatitude,
      checkOutLongitude: event.checkOutLongitude,
      );

      emit(AttendanceSuccess());
    } on DioException catch (e) {
       emit(
      AttendanceFailure(message: _dioMessage(e, fallback: 'Check-out failed')),
    );
    } catch (_) {
       emit(AttendanceFailure(message: 'An error occurred during check-out'));
    }
  }

  Future<void> _onTodayAttendanceRequested(
    TodayAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(TodayAttendanceLoading());

    try {
      final attendance = await attendanceRemoteDatasource.getTodayAttendance();
      emit(TodayAttendanceLoaded(attendance: attendance));
    } on DioException catch (e) {
      emit(
        AttendanceFailure(
          message: _dioMessage(e, fallback: 'Could not load today attendance'),
        ),
      );
    } catch (_) {
      emit(AttendanceFailure(message: 'Could not load today attendance'));
    }
  }

  String _dioMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message']?.toString() ?? fallback;
      final distanceMeters = data['distance_meters'];
      final allowedRadiusMeters = data['allowed_radius_meters'];

      if (distanceMeters != null && allowedRadiusMeters != null) {
        final distance = _formatNumber(distanceMeters);
        final radius = _formatNumber(allowedRadiusMeters);

        return '$message (distance: ${distance}m, allowed: ${radius}m)';
      }

      return message;
    }

    return fallback;
  }

  String _formatNumber(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    return number.toStringAsFixed(0);
  }
}
