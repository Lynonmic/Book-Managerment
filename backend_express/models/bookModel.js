const db = require('../config/database');

class BookModel {
  static async getAllBooks() {
    try {
      const [rows] = await db.query(`
        SELECT 
          ma_sach as id,
          ten_sach as title,
          tac_gia as author,
          mo_ta as description,
          url_anh as image_url,
          gia as price,
          ma_nha_xuat_ban as publisher_id,
          so_luong as quantity,
          ngay_tao as created_at,
          ngay_cap_nhat as updated_at
        FROM books
      `);
      return rows;
    } catch (error) {
      throw error;
    }
  }

  static async getBookById(id) {
    try {
      const [rows] = await db.query('SELECT * FROM books WHERE id = ?', [id]);
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async createBook(bookData) {
    try {
      const [result] = await db.query(
        'INSERT INTO books (title, author, description, image_url, price, publisher, page_count, isbn, rating, rating_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          bookData.title,
          bookData.author,
          bookData.description,
          bookData.imageUrl,
          bookData.price,
          bookData.publisher,
          bookData.pageCount,
          bookData.isbn,
          bookData.rating,
          bookData.ratingCount
        ]
      );
      return result.insertId;
    } catch (error) {
      throw error;
    }
  }

  static async updateBook(id, bookData) {
    try {
      const [result] = await db.query(
        'UPDATE books SET title = ?, author = ?, description = ?, image_url = ?, price = ?, publisher = ?, page_count = ?, isbn = ?, rating = ?, rating_count = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [
          bookData.title,
          bookData.author,
          bookData.description,
          bookData.imageUrl,
          bookData.price,
          bookData.publisher,
          bookData.pageCount,
          bookData.isbn,
          bookData.rating,
          bookData.ratingCount,
          id
        ]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }

  static async deleteBook(id) {
    try {
      const [result] = await db.query('DELETE FROM books WHERE id = ?', [id]);
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = BookModel;
