abstract class ForgotPasswordEvent {}

class SendOtpEvent extends ForgotPasswordEvent {
  final String email;

  SendOtpEvent({required this.email});
}

class VerifyOtpEvent extends ForgotPasswordEvent {
  final String email;
  final String otp;

  VerifyOtpEvent({required this.email, required this.otp});
}

class ResetPasswordEvent extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}

