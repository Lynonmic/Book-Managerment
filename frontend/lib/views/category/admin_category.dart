import 'package:flutter/material.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/categories/category_provider.dart';
import 'package:frontend/views/category/category_item.dart';
import 'package:frontend/views/category/edit_category_screen.dart';
import 'package:frontend/widget/floating_button.dart';
import 'package:provider/provider.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({Key? key}) : super(key: key);

  @override
  _AdminCategoryScreenState createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch categories when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add New Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    final newCategory = CategoryModel(
                      name: _nameController.text,
                    );

                    final provider = Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    );
                    final result = await provider.addCategory(newCategory);

                    Navigator.pop(context);

                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Category added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add category: ${provider.error}',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category name cannot be empty')),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _navigateToEditCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: category),
      ),
    );
  }

  void _showDeleteConfirmationDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final provider = Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  );
                  final success = await provider.deleteCategory(category.id!);

                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category deleted successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to delete category: ${provider.error}',
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categoryProvider.error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => categoryProvider.fetchCategories(isRetry: true),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (categoryProvider.categories.isEmpty) {
          return Stack(
            children: [
              Center(child: Text('No categories found')),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingButton(
                  onPressed: _showAddCategoryDialog,
                  tooltip: 'Add Category',
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];

                return Dismissible(
                  key: Key(category.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    _showDeleteConfirmationDialog(category);
                    return false; // Don't dismiss automatically
                  },
                  child: CategoryItem(
                    name: category.name,
                    onTap: () => _navigateToEditCategory(category),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingButton(
                onPressed: _showAddCategoryDialog,
                tooltip: 'Add Category',
              ),
            ),
          ],
        );
      },
    );
  }
}
