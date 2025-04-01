import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/category_model.dart';

class CategoryService {
  final String baseUrl =
      'http://10.0.2.2:3000/api'; // Replace with your API base URL

  // Fetch all categories
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Check if the response is a Map with a data field containing the list
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        }
        // Check if response is directly a List
        else if (data is List) {
          return data.map((json) => CategoryModel.fromJson(json)).toList();
        }
        // If it's something else unexpected
        else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Create a new category
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ten_danh_muc': category.name}),
      );

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  // Update an existing category
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      if (category.id == null) {
        throw Exception('Category ID cannot be null for update');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/categories/${category.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ten_danh_muc': category.name}),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$categoryId'),
      );

      if (response.statusCode == 200) {
        return true; // Successful deletion
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
