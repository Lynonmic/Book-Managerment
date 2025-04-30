import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/category/category_event.dart';
import 'package:frontend/blocs/category/category_state.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryById>(_onLoadCategoryById);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await _categoryRepository.getCategories();
      emit(state.copyWith(categories: categories, status: CategoryStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCategoryById(
      LoadCategoryById event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final category = await _categoryRepository.getCategoryById(event.id);
      emit(state.copyWith(selectedCategory: category, status: CategoryStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final newCategory = await _categoryRepository.createCategory(event.category);
      final updatedCategories = List<CategoryModel>.from(state.categories)..add(newCategory);
      emit(state.copyWith(
        categories: updatedCategories,
        status: CategoryStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final updatedCategory = await _categoryRepository.updateCategory(event.category);
      final updatedCategories = state.categories.map((category) {
        return category.id == updatedCategory.id ? updatedCategory : category;
      }).toList();
      emit(state.copyWith(
        categories: updatedCategories,
        selectedCategory: updatedCategory,
        status: CategoryStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final success = await _categoryRepository.deleteCategory(event.id);
      if (success) {
        final updatedCategories = state.categories.where((category) => category.id != event.id).toList();
        emit(state.copyWith(
          categories: updatedCategories,
          status: CategoryStatus.loaded,
        ));
      } else {
        emit(state.copyWith(
          status: CategoryStatus.error,
          errorMessage: 'Failed to delete category',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
