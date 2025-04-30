import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/category/category_bloc.dart';
import 'package:frontend/blocs/category/category_event.dart';
import 'package:frontend/blocs/category/category_state.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/screens/widget/floating_button.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.status == CategoryStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'An error occurred',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CategoryBloc>().add(LoadCategories()),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.categories.isEmpty) {
          return Center(child: Text('No categories found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<CategoryBloc>().add(LoadCategories());
                return Future.delayed(Duration(milliseconds: 300));
              },
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        category.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditCategoryDialog(context, category);
                          } else if (value == 'delete') {
                            _showDeleteCategoryConfirmationDialog(context, category);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingButton(
                onPressed: () {
                  _showAddCategoryDialog(context);
                },
                tooltip: 'Add Category',
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.read<CategoryBloc>().add(
                        AddCategory(
                          CategoryModel(
                            id: null,
                            name: nameController.text.trim(),
                          ),
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category added')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final TextEditingController nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.read<CategoryBloc>().add(
                        UpdateCategory(
                          CategoryModel(
                            id: category.id,
                            name: nameController.text.trim(),
                          ),
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category updated')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryConfirmationDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CategoryBloc>().add(DeleteCategory(category.id!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
