import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
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
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Consumer<AuthController>(
                  builder: (context, controller, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey<int>(controller.step),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.step == 1) buildEmailInput(context, controller),
                          if (controller.step == 2) buildOtpInput(context, controller),
                          if (controller.step == 3) buildResetPasswordInput(context, controller),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailInput(BuildContext context, AuthController controller) {
    return buildInputSection(
      "Nhập Email", 
      "Email", 
      Icons.email, 
      controller.emailController, 
      () => controller.sendOtp(context),
      "Gửi OTP",
      Colors.purpleAccent,
    );
  }

  Widget buildOtpInput(BuildContext context, AuthController controller) {
    return buildInputSection(
      "Nhập mã OTP", 
      "OTP", 
      Icons.lock, 
      controller.otpController, 
      () => controller.verifyOtp(context),
      "Xác thực OTP",
      Colors.purpleAccent,
    );
  }

  Widget buildResetPasswordInput(BuildContext context, AuthController controller) {
    return buildInputSection(
      "Đổi mật khẩu", 
      "Mật khẩu mới", 
      Icons.lock_reset, 
      controller.newPasswordController, 
      () => controller.resetPassword(context),
      "Đổi mật khẩu",
      Colors.purpleAccent,
      obscureText: true,
    );
  }

  Widget buildInputSection(
      String title, String hintText, IconData icon, TextEditingController controller, VoidCallback onPressed, String buttonText, Color buttonColor, {bool obscureText = false}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(buttonText, style: const TextStyle(fontSize: 16,color: Colors.white)),
        ),
      ],
    );
  }
}
