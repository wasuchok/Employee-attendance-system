import 'package:app/features/character/data/datasources/character_remote_datasource.dart';
import 'package:app/features/character/presentation/bloc/character_event.dart';
import 'package:app/features/character/presentation/bloc/character_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRemoteDatasource characterRemoteDatasource;

  CharacterBloc({required this.characterRemoteDatasource})
    : super(CharacterInitial()) {
    on<CreateEmployeeProfileRequested>(_onCreateEmployeeProfile);
  }

  Future<void> _onCreateEmployeeProfile(
    CreateEmployeeProfileRequested event,
    Emitter<CharacterState> emit,
  ) async {
    emit(CharacterLoading());

    try {
      await characterRemoteDatasource.ensureEmployeeProfile(
        employeeCode: event.employeeCode,
        fullName: event.fullName,
        position: event.position,
        phone: event.phone,
        avatarUrl: event.avatarUrl,
      );

      emit(CharacterSuccess());
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message']?.toString() : null;

      emit(
        CharacterFailure(
          message: message ?? 'Could not create employee profile',
        ),
      );
    } catch (_) {
      emit(CharacterFailure(message: 'Could not create employee profile.'));
    }
  }
}
