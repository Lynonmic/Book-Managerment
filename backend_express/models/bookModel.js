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
      const [rows] = await db.query('SELECT * FROM books WHERE ma_sach = ?', [id]);
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async createBook(bookData) {
    try {
      // Validate required fields
      if (!bookData.title || !bookData.imageUrl || !bookData.price || !bookData.publisherId) {
        throw new Error('Missing required fields: title, imageUrl, price, or publisherId');
      }

      const [result] = await db.query(
        `INSERT INTO books (ten_sach, tac_gia, mo_ta, url_anh, gia, ma_nha_xuat_ban, so_luong, ngay_tao, ngay_cap_nhat) 
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
        [
          bookData.title,
          bookData.author || null, // Allow author to be optional
          bookData.description || null, // Allow description to be optional
          bookData.imageUrl,
          bookData.price,
          bookData.publisherId,
          bookData.quantity 
        ]
      );
      return result.insertId;
    } catch (error) {
      throw error;
    }
  }

  static async updateBook(id, bookData) {
    try {
      console.log(`Updating book with ID ${id}:`, bookData);
      
      // Query to check if the book exists first
      const [checkBook] = await db.query('SELECT ma_sach FROM books WHERE ma_sach = ?', [id]);
      
      if (checkBook.length === 0) {
        console.log(`Book with ID ${id} not found in database`);
        return 0; // Book not found
      }
      
      console.log(`Book with ID ${id} exists in database`);
      
      // Construct the query based on the provided data
      let updateFields = [];
      let values = [];
      
      if (bookData.title) {
        updateFields.push('ten_sach = ?');
        values.push(bookData.title);
      }
      
      if (bookData.author) {
        updateFields.push('tac_gia = ?');
        values.push(bookData.author);
      }
      
      if (bookData.description !== undefined) {
        updateFields.push('mo_ta = ?');
        values.push(bookData.description);
      }
      
      if (bookData.price) {
        updateFields.push('gia = ?');
        values.push(bookData.price);
      }
      
      if (bookData.imageUrl) {
        updateFields.push('url_anh = ?');
        values.push(bookData.imageUrl);
      }
      
      if (bookData.category) {
        updateFields.push('category = ?');
        values.push(bookData.category);
      }
      
      if (bookData.publisherId) {
        updateFields.push('ma_nha_xuat_ban = ?');
        values.push(bookData.publisherId);
      }
      
      if (bookData.rating) {
        updateFields.push('rating = ?');
        values.push(bookData.rating);
      }
      
      // If no fields to update, return
      if (updateFields.length === 0) {
        console.log('No fields to update');
        return 0;
      }
      
      // Add the WHERE clause value at the end
      values.push(id);
      
      const query = `UPDATE books SET ${updateFields.join(', ')} WHERE ma_sach = ?`;
      console.log('Update query:', query);
      console.log('Update values:', values);
      
      const [result] = await db.query(query, values);
      console.log('Update result:', result);
      return result.affectedRows;
    } catch (error) {
      console.error('Error in updateBook:', error);
      throw error;
    }
  }

  static async deleteBook(id) {
    try {
      console.log(`Deleting book with ID ${id}`);
      const [result] = await db.query('DELETE FROM books WHERE ma_sach = ?', [id]);
      return result.affectedRows;
    } catch (error) {
      console.error('Error in deleteBook:', error);
      throw error;
    }
  }
}

module.exports = BookModel;
