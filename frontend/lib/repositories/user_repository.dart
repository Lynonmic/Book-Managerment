import 'dart:io';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/service/api_service.dart';

class UserRepository {
  Future<List<UserModels>> fetchAllUsers() async {
    return await ApiService.getAllUser();
  }

  Future<UserModels> getUserById(int id) async {
    final profile = await ApiService.getUserProfile("");
    if (profile["success"]) {
      return UserModels.fromJson(profile["user"]);
    } else {
      throw Exception(profile["message"] ?? "Lỗi không xác định!");
    }
  }

  Future<Map<String, dynamic>?> updateUser({
    required int userId,
    String? tenKhachHang,
    String? soDienThoai,
    String? diaChi,
    String? email,
    File? avatar,
  }) async {
    return await ApiService.updateUser(
      userId: userId,
      tenKhachHang: tenKhachHang,
      soDienThoai: soDienThoai,
      diaChi: diaChi,
      email: email,
      avatar: avatar,
    );
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    return await ApiService.deleteUser(userId);
  }

  Future<List<UserModels>> searchUsers(String query) async {
    try {
      final apiService = ApiService();
      final response = await apiService.searchUsers(query);
      return (response as List<dynamic>)
          .map((user) => UserModels.fromJson(user as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}
