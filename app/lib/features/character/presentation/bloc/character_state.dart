import 'package:flutter/foundation.dart';

@immutable
sealed class CharacterState {}

final class CharacterInitial extends CharacterState {}

final class CharacterLoading extends CharacterState {}

final class CharacterSuccess extends CharacterState {}

final class CharacterFailure extends CharacterState {
  final String message;

  CharacterFailure({required this.message});
}
