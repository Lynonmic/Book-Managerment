import 'package:frontend/model/UserModels.dart';

abstract class SearchUserState {}

class SearchUserInitial extends SearchUserState {}

class SearchUserLoading extends SearchUserState {}

class SearchUserSuccess extends SearchUserState {
  final List<UserModels> results;
  SearchUserSuccess(this.results);
}

class SearchUserError extends SearchUserState {
  final String message;
  SearchUserError(this.message);
}
