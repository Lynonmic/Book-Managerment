import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/service/api_service.dart';

class UsersController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<List<UserModels>> fetchUsers() async {
    try {
      List<UserModels> users = await ApiService.getAllUser();

      return users;
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  Future<void> updateUserProfile({
    required int userId,
    String? name,
    String? phone,
    String? address,
    String? email,
    File? avatarFile,
    required String adminToken, // Token của admin
    required BuildContext context,
  }) async {
    var response = await ApiService.updateUser(
      userId: userId,
      tenKhachHang: name,
      soDienThoai: phone,
      diaChi: address,
      email: email,
      avatar: avatarFile,
      token: adminToken, // Gửi token của admin
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["success"]
              ? "✅ ${response['message']}"
              : "❌ ${response['message']}",
        ),
      ),
    );
  }

  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    notifyListeners(); // Cập nhật UI để hiển thị loading

    final response = await ApiService.deleteUser(userId);

    _isLoading = false;
    if (response["success"]) {
      notifyListeners();
      return true; // Xóa thành công
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false; // Xóa thất bại
    }
  }
}
