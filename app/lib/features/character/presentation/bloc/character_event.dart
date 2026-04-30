import 'package:flutter/foundation.dart';

@immutable
sealed class CharacterEvent {}

final class CreateEmployeeProfileRequested extends CharacterEvent {
  final String employeeCode;
  final String fullName;
  final String position;
  final String phone;
  final String avatarUrl;

  CreateEmployeeProfileRequested({
    required this.employeeCode,
    required this.fullName,
    required this.position,
    required this.phone,
    required this.avatarUrl,
  });
}
