import 'package:app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRemoteDatasource attendanceRemoteDatasource;

  AttendanceBloc({required this.attendanceRemoteDatasource})
    : super(AttendanceInitial()) {
    on<CheckInRequested>(_onCheckIn);
  }

  Future<void> _onCheckIn(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

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
        AttendanceFailure(
          message: e.response?.data['message'] ?? 'Check-in failed',
        ),
      );
    } catch (_) {
      emit(AttendanceFailure(message: 'An error occurred during check-in'));
    }
  }
}
