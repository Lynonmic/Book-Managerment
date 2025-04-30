

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> userData;
  final int role;
  final String token;

  AuthSuccess({required this.userData, required this.role, required this.token});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}

