abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email; 

  ForgotPasswordOtpSent({required this.email});
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {}

class ForgotPasswordResetSuccess extends ForgotPasswordState {}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;

  ForgotPasswordFailure({required this.message});
}
