import 'package:flutter/material.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/categories/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch all categories
  Future<void> fetchCategories({bool isRetry = false}) async {
    if (_isLoading && !isRetry) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final categories = await _categoryService.fetchCategories();
      _categories = categories;
      _isLoading = false;
      print('Fetched categories: $_categories');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error fetching categories: $_error');
      notifyListeners();
    }
  }

  // Create a new category
  Future<CategoryModel?> addCategory(CategoryModel category) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _categoryService.createCategory(category);
      _categories.add(result);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update an existing category
  Future<CategoryModel?> updateCategory(CategoryModel category) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _categoryService.updateCategory(category);

      // Update the category in the list
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = result;
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _categoryService.deleteCategory(categoryId);

      if (success) {
        // Remove the category from the list
        _categories.removeWhere((c) => c.id == categoryId);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Widget refreshCategories() {
    return const SizedBox.shrink(); // Return an empty widget
  }
}
