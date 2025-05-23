import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/forgot_pass/forgot_password_bloc.dart';
import 'package:frontend/blocs/forgot_pass/forgot_password_event.dart';
import 'package:frontend/blocs/forgot_pass/forgot_password_state.dart';
import 'package:frontend/repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    // Đừng quên giải phóng tài nguyên khi widget bị hủy
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(authRepository: AuthRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quên mật khẩu"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
                    listener: (context, state) {
                      if (state is ForgotPasswordOtpSent) {
                        _showMessage(context, "OTP đã được gửi!");
                      } else if (state is ForgotPasswordOtpVerified) {
                        _showMessage(context, "OTP xác thực thành công!");
                      } else if (state is ForgotPasswordResetSuccess) {
                        _showMessage(
                          context,
                          "Đổi mật khẩu thành công!",
                          shouldPop: true,
                        );
                      } else if (state is ForgotPasswordFailure) {
                        _showMessage(context, state.message);
                      }
                    },
                    child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state is ForgotPasswordInitial)
                              _buildEmailInput(context)
                            else if (state is ForgotPasswordOtpSent)
                              _buildOtpInput(context)
                            else if (state is ForgotPasswordOtpVerified)
                              _buildResetPasswordInput(context),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool shouldPop = false,
  }) {
    final snackBar = SnackBar(content: Text(message));
    final messenger = ScaffoldMessenger.of(context);
    final controller = messenger.showSnackBar(snackBar);

    if (shouldPop) {
      controller.closed.then((reason) {
        Navigator.pop(context);
      });
    }
  }

  Widget _buildEmailInput(BuildContext context) {
    return _buildInputSection(
      "Nhập Email",
      "Email",
      Icons.email,
      _emailController,
      () {
        final email = _emailController.text.trim();
        if (email.isNotEmpty) {
          context.read<ForgotPasswordBloc>().add(SendOtpEvent(email: email));
        }
      },
      "Gửi OTP",
    );
  }

  Widget _buildOtpInput(BuildContext context) {
    return _buildInputSection(
      "Nhập mã OTP",
      "OTP",
      Icons.lock,
      _otpController,
      () {
        final otp = _otpController.text.trim();
        if (otp.isNotEmpty) {
          final email = _emailController.text.trim();
          context.read<ForgotPasswordBloc>().add(
            VerifyOtpEvent(otp: otp, email: email),
          );
        }
      },
      "Xác thực OTP",
    );
  }

  Widget _buildResetPasswordInput(BuildContext context) {
    return _buildInputSection(
      "Đổi mật khẩu",
      "Mật khẩu mới",
      Icons.lock_reset,
      _newPasswordController,
      () {
        final newPassword = _newPasswordController.text.trim();
        if (newPassword.isNotEmpty) {
          final email = _emailController.text.trim();
          final otp = _otpController.text.trim();
          context.read<ForgotPasswordBloc>().add(
            ResetPasswordEvent(
              newPassword: newPassword,
              email: email,
              otp: otp,
            ),
          );
        }
      },
      "Đổi mật khẩu",
      obscureText: true,
    );
  }

  Widget _buildInputSection(
    String title,
    String hintText,
    IconData icon,
    TextEditingController controller,
    VoidCallback onPressed,
    String buttonText, {
    bool obscureText = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: hintText,
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.purpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
