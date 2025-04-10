import 'package:flutter/material.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/categories/category_provider.dart';
import 'package:provider/provider.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const EditCategoryScreen({Key? key, this.category}) : super(key: key);

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  bool get isEditMode => widget.category != null && widget.category?.id != 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category name cannot be empty')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedCategory = CategoryModel(
      id: widget.category!.id,
      name: _nameController.text,
    );

    final provider = Provider.of<CategoryProvider>(context, listen: false);

    final result = await provider.updateCategory(updatedCategory);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category updated successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update category: ${provider.error}')),
      );
    }
  }

  Future<void> _createCategory() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);

    final newCategory = CategoryModel(
      id: 0, // Backend will assign the actual ID
      name: _nameController.text,
    );

    try {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final result = await provider.addCategory(newCategory);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create category: ${provider.error}'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Category'),
            content: Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final provider = Provider.of<CategoryProvider>(context, listen: false);
        final success = await provider.deleteCategory(widget.category!.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category deleted successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete category: ${provider.error}'),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Category' : 'Create Category'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteCategory,
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isEditMode ? _updateCategory : _createCategory,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isEditMode ? _updateCategory : _createCategory,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        isEditMode ? 'Update Category' : 'Create Category',
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
