import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/api_service.dart';

class CategoryRepository {
  List<CategoryModel> _categories = [];

  Future<List<CategoryModel>> getCategories() async {
    try {
      _categories = await ApiService.getAllCategories();
      return _categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel> getCategoryById(int id) async {
    try {
      return await ApiService.getCategoryById(id);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await ApiService.createCategory(category);
      if (response['success']) {
        // Refresh categories to get the newly created one
        await getCategories();
      
        return _categories.last;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final response = await ApiService.updateCategory(category.id!, category);
      if (response['success']) {
        // Get the updated category
        final updatedCategory = await getCategoryById(category.id!);
        // Update local cache
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
        return updatedCategory;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await ApiService.deleteCategory(id);
      if (response['success']) {
        _categories.removeWhere((category) => category.id == id);
        return true;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
