import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';

class PositionRepo {
  // Lấy tất cả các trường vị trí
  static Future<List<Map<String, dynamic>>> getPositionFields() async {
    try {
      final response =
          await ApiService.getPositionFields(); // Gọi API từ ApiService
      return response; // Trả về danh sách các trường vị trí
    } catch (e) {
      throw Exception('Failed to load position fields: $e');
    }
  }

  // Thêm vị trí cho sách
  static Future<Map<String, dynamic>> addBookPosition(
    int bookId,
    int positionFieldId,
    String positionValue,
  ) async {
    try {
      final response = await ApiService.addBookPosition(
        bookId,
        positionFieldId,
        positionValue,
      ); // Gọi API từ ApiService
      return response; // Trả về kết quả khi thêm vị trí sách
    } catch (e) {
      throw Exception('Failed to add book position: $e');
    }
  }

  // Lấy các vị trí của sách theo ID
  static Future<List<Map<String, dynamic>>> getBookPositions(int bookId) async {
    try {
      final response = await ApiService.getBookPositions(
        bookId,
      ); // Gọi API từ ApiService
      return response; // Trả về danh sách các vị trí của sách
    } catch (e) {
      throw Exception('Failed to load book positions: $e');
    }
  }

  // Trong repository
  static Future<void> addPositionField(
    String positionName,
    BuildContext context,
  ) async {
    try {
      await ApiService.addPositionField(
        positionName,
        context,
      ); // Gọi API từ ApiService và truyền BuildContext
      print('Position added successfully');
    } catch (e) {
      print('Error occurred while adding position: $e');
      throw Exception('Failed to add position: $e');
    }
  }

  static Future<void> updatePositionField({
    required int id,
    required String newName,
  }) async {
    try {
      await ApiService.updatePositionField(id: id, newName: newName);
      print('Position updated successfully');
    } catch (e) {
      print('Error occurred while updating position: $e');
      throw Exception('Failed to update position: $e');
    }
  }

  // Gọi API xóa trường vị trí
  static Future<void> deletePositionField({required int id}) async {
    try {
      await ApiService.deletePositionField(id: id);
      print('Position deleted successfully');
    } catch (e) {
      print('Error occurred while deleting position: $e');
      throw Exception('Failed to delete position: $e');
    }
  }

  // Cập nhật vị trí sách
  static Future<void> updateBookPosition({
    required int bookId,
    required int positionFieldId,
    required String newValue,
  }) async {
    try {
      await ApiService.updateBookPosition(
        bookId: bookId,
        positionFieldId: positionFieldId,
        newValue: newValue,
      );
      print('Book position updated successfully');
    } catch (e) {
      print('Error updating book position: $e');
      throw Exception('Failed to update book position: $e');
    }
  }

  // Xóa một vị trí cụ thể của sách
  static Future<void> deleteBookPosition({
    required int bookId,
    required int positionFieldId,
  }) async {
    try {
      await ApiService.deleteBookPosition(
        bookId: bookId,
        positionFieldId: positionFieldId,
      );
      print('Book position deleted successfully');
    } catch (e) {
      print('Error deleting book position: $e');
      throw Exception('Failed to delete book position: $e');
    }
  }

  // Xóa toàn bộ vị trí của sách
  static Future<void> clearAllBookPositions({required int bookId}) async {
    try {
      await ApiService.clearAllBookPositions(bookId);
      print('All book positions cleared');
    } catch (e) {
      print('Error clearing book positions: $e');
      throw Exception('Failed to clear book positions: $e');
    }
  }
}
