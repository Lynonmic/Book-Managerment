import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc({required this.authRepository})
      : super(ForgotPasswordInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());  // Hiển thị trạng thái loading

    try {
      final response = await authRepository.sendOtp(event.email);
      if (response["success"]) {
        emit(ForgotPasswordOtpSent(email: event.email));  // Gửi email vào state
      } else {
        emit(ForgotPasswordFailure(message: response["message"]));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());  // Hiển thị trạng thái loading

    try {
      final response = await authRepository.verifyOtp(
        event.email,  // Truyền email
        event.otp,
      );
      if (response["success"]) {
        emit(ForgotPasswordOtpVerified());
      } else {
        emit(ForgotPasswordFailure(message: response["message"]));  // Thông báo lỗi
        emit(ForgotPasswordOtpSent(email: event.email));  // Quay lại nhập OTP
      }
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString()));  // Thông báo lỗi
      emit(ForgotPasswordOtpSent(email: event.email));  // Quay lại nhập OTP
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());  // Hiển thị trạng thái loading

    try {
      final response = await authRepository.resetPassword(
        event.email,  // Truyền email
        event.otp,    // Truyền OTP
        event.newPassword,  // Truyền mật khẩu mới
      );
      if (response["success"]) {
        emit(ForgotPasswordResetSuccess());
      } else {
        emit(ForgotPasswordFailure(message: response["message"]));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString()));
    }
  }
}
