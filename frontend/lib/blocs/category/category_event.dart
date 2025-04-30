import 'package:equatable/equatable.dart';
import 'package:frontend/model/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class LoadCategoryById extends CategoryEvent {
  final int id;

  const LoadCategoryById(this.id);

  @override
  List<Object?> get props => [id];
}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}
