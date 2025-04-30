import 'package:equatable/equatable.dart';
import 'package:frontend/model/category_model.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final CategoryStatus status;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.selectedCategory,
    this.status = CategoryStatus.initial,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    CategoryStatus? status,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategory, status, errorMessage];
}
