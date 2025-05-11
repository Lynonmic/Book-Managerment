
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';

class PositionRepo {
  // Lấy tất cả các trường vị trí
  static Future<List<Map<String, dynamic>>> getPositionFields() async {
    try {
      final response = await ApiService.getPositionFields(); // Gọi API từ ApiService
      return response; // Trả về danh sách các trường vị trí
    } catch (e) {
      throw Exception('Failed to load position fields: $e');
    }
  }

  // Thêm vị trí cho sách
  static Future<Map<String, dynamic>> addBookPosition(int bookId, int positionFieldId, String positionValue) async {
    try {
      final response = await ApiService.addBookPosition(bookId, positionFieldId, positionValue); // Gọi API từ ApiService
      return response; // Trả về kết quả khi thêm vị trí sách
    } catch (e) {
      throw Exception('Failed to add book position: $e');
    }
  }

  // Lấy các vị trí của sách theo ID
  static Future<List<Map<String, dynamic>>> getBookPositions(int bookId) async {
    try {
      final response = await ApiService.getBookPositions(bookId); // Gọi API từ ApiService
      return response; // Trả về danh sách các vị trí của sách
    } catch (e) {
      throw Exception('Failed to load book positions: $e');
    }
  }

  // Trong repository
static Future<void> addPositionField(String positionName, BuildContext context) async {
  try {
    await ApiService.addPositionField(positionName, context); // Gọi API từ ApiService và truyền BuildContext
    print('Position added successfully');
  } catch (e) {
    print('Error occurred while adding position: $e');
    throw Exception('Failed to add position: $e');
  }
}

}
