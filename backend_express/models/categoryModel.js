const db = require('../config/database');

class CategoryModel {
  // Get all categories
  static async getAllCategories() {
    try {
      const [rows] = await db.query('SELECT id, ten_danh_muc as name FROM categories');
      return rows;
    } catch (error) {
      throw error;
    }
  }

  // Get category by ID
  static async getCategoryById(id) {
    try {
      const [rows] = await db.query('SELECT id, ten_danh_muc as name FROM categories WHERE id = ?', [id]);
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  // Create a new category
  static async createCategory(categoryData) {
    try {
      if (!categoryData.name) {
        throw new Error('Missing required field: name');
      }

      const [result] = await db.query(
        'INSERT INTO categories (ten_danh_muc) VALUES (?)',
        [categoryData.name]
      );
      return result.insertId;
    } catch (error) {
      throw error;
    }
  }

  // Update a category
  static async updateCategory(id, categoryData) {
    try {
      if (!categoryData.name) {
        throw new Error('Missing required field: name');
      }

      const [checkCategory] = await db.query('SELECT id FROM categories WHERE id = ?', [id]);
      if (checkCategory.length === 0) {
        return 0; // Category not found
      }

      const [result] = await db.query(
        'UPDATE categories SET ten_danh_muc = ? WHERE id = ?',
        [categoryData.name, id]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }

  // Delete a category
  static async deleteCategory(id) {
    try {
      const [result] = await db.query('DELETE FROM categories WHERE id = ?', [id]);
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = CategoryModel;