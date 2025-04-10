// controllers/categoryController.js
const CategoryModel = require('../models/categoryModel');

// Helper function to format category response
const formatCategoryResponse = (category) => {
  if (!category) return null;
  
  return {
    id: category.id || category.ma_danh_muc,
    name: category.ten_danh_muc || category.name,
  };
};

// Get all categories
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await CategoryModel.getAllCategories();
    res.status(200).json({
      success: true,
      data: categories.map(category => formatCategoryResponse(category))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories',
      error: error.message
    });
  }
};

// Get a single category by ID
exports.getCategoryById = async (req, res) => {
  try {
    const category = await CategoryModel.getCategoryById(req.params.id);
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }
    res.status(200).json({
      success: true,
      data: formatCategoryResponse(category)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch category',
      error: error.message
    });
  }
};

// Create a new category
exports.createCategory = async (req, res) => {
  try {
    console.log('Creating category with data:', req.body);
    const categoryId = await CategoryModel.createCategory(req.body);
    const newCategory = await CategoryModel.getCategoryById(categoryId);
    
    console.log('Created category:', newCategory);
    res.status(201).json({
      success: true,
      data: formatCategoryResponse(newCategory)
    });
  } catch (error) {
    console.error('Error creating category:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create category',
      error: error.message
    });
  }
};

// Update a category
exports.updateCategory = async (req, res) => {
  try {
    console.log('Updating category:', req.params.id, 'with data:', req.body);
    const affected = await CategoryModel.updateCategory(req.params.id, req.body);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Category not found or no changes made'
      });
    }
    const updatedCategory = await CategoryModel.getCategoryById(req.params.id);
    res.status(200).json({
      success: true,
      data: formatCategoryResponse(updatedCategory)
    });
  } catch (error) {
    console.error('Error updating category:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update category',
      error: error.message
    });
  }
};

// Delete a category
exports.deleteCategory = async (req, res) => {
  try {
    const affected = await CategoryModel.deleteCategory(req.params.id);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }
    res.status(200).json({
      success: true,
      message: 'Category deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete category',
      error: error.message
    });
  }
};