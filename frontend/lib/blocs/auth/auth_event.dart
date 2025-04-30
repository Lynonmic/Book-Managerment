import 'dart:io';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final File? avatar;

  AuthSignUpEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    this.avatar,
  });
}

class AuthSignOutEvent extends AuthEvent {}