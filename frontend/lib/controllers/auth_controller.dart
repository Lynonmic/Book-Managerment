import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMess = '';

  bool get isLoading => _isLoading;
  String get errorMess => _errorMess;

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await ApiService.loginUser(email, password);

    if (result['success']) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMess = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    File? avatar,
  }) async {
    _isLoading = true;
    _errorMess = '';
    notifyListeners();

    final result = await ApiService.registerUser(
      name,
      email,
      password,
      phone,
      address,
      avatar,
    );

    if (result['success']) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMess = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  int step = 1;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  void nextStep() {
    step++;
    notifyListeners();
  }

  void previousStep() {
    step--;
    notifyListeners();
  }

  Future<void> sendOtp(BuildContext context) async {
    bool success = await ApiService.sendOtp(emailController.text);
    if (success) {
      nextStep();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mã OTP đã được gửi!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gửi OTP thất bại!")));
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    bool success = await ApiService.verifyOtp(emailController.text, otpController.text);
    if (success) {
      nextStep();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP hợp lệ, đặt lại mật khẩu!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP không hợp lệ!")));
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    bool success = await ApiService.resetPassword(
      emailController.text,
      otpController.text,
      newPasswordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đổi mật khẩu thành công!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đổi mật khẩu thất bại!")));
    }
  }
  
}
