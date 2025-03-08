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
}
