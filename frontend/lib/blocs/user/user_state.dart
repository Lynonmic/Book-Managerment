import 'package:frontend/model/UserModels.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModels> users;

  UserLoaded(this.users);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {
  final String message;

  UserUpdated({required this.message});
}

class UserDeleting extends UserState {}

class UserDeleted extends UserState {
  final String message;

  UserDeleted({required this.message});
}