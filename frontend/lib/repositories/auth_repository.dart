import 'dart:io';

import 'package:frontend/service/api_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await ApiService.loginUser(email, password);
  }

  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String phone,
    String address,
    File? avatar,
  ) async {
    return await ApiService.registerUser(
      name,
      email,
      password,
      phone,
      address,
      avatar,
    );
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      bool success = await ApiService.sendOtp(email);
      return {
        "success": success,
        "message": success ? "OTP sent successfully" : "Failed to send OTP",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      bool success = await ApiService.verifyOtp(email, otp);
      return {
        "success": success,
        "message": success ? "OTP verified successfully" : "Invalid OTP",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      bool success = await ApiService.resetPassword(email, otp, newPassword);
      return {
        "success": success,
        "message":
            success ? "Password reset successful" : "Failed to reset password",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
