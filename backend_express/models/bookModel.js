const db = require("../config/database");

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
          series_id,
          ngay_tao as created_at,
          ngay_cap_nhat as updated_at
        FROM books
        WHERE is_deleted = 1
      `);
      return rows;
    } catch (error) {
      throw error;
    }
  }

  static async getBookById(id) {
    try {
      const [rows] = await db.query(
        "SELECT * FROM books WHERE ma_sach = ? AND is_deleted = 1",
        [id]
      );
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async createBook(bookData) {
    try {
      // Validate required fields
      if (!bookData.title || !bookData.price) {
        throw new Error("Missing required fields: title, imageUrl, or price");
      }

      // Enhanced logging to debug publisherId
      console.log("Creating book with detailed data:");
      console.log("- publisherId:", bookData.publisherId);
      console.log("- Type of publisherId:", typeof bookData.publisherId);
      console.log("- All book data:", bookData);
      console.log("- All book data:", bookData.quantity);

      const [result] = await db.query(
        `INSERT INTO books (ten_sach, url_anh, tac_gia, ma_danh_muc, ma_nha_xuat_ban, gia, so_luong, mo_ta, series_id, is_deleted, ngay_tao, ngay_cap_nhat) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())`,
        [
          bookData.title,
          bookData.imageUrl ||
            "https://res.cloudinary.com/dyxy8asve/image/upload/v1746379642/dacnhantam86_vgjoyu.jpg",
          bookData.author || null, // Allow author to be optional
          bookData.category || null, // Add category ID (ma_danh_muc)
          bookData.publisherId || null, // Publisher ID (ma_nha_xuat_ban)
          bookData.price,
          bookData.quantity || 0, // Default quantity to 0 if not provided
          bookData.description || null, // Allow description to be optional
          bookData.seriesId || null, // Series ID
        ]
      );
      return result.insertId;
    } catch (error) {
      console.error("Error in createBook:", error);
      throw error;
    }
  }

  static async updateBook(id, bookData) {
    try {
      // Query to check if the book exists first
      const [checkBook] = await db.query(
        "SELECT ma_sach FROM books WHERE ma_sach = ? AND is_deleted = 1",
        [id]
      );

      if (checkBook.length === 0) {
        console.log(
          `Book with ID ${id} not found in database or has been deleted`
        );
        return 0; // Book not found
      }

      console.log(`Book with ID ${id} exists in database`);

      // Construct the query based on the provided data
      let updateFields = [];
      let values = [];

      if (bookData.title) {
        updateFields.push("ten_sach = ?");
        values.push(bookData.title);
      }

      if (bookData.author) {
        updateFields.push("tac_gia = ?");
        values.push(bookData.author);
      }

      if (bookData.description !== undefined) {
        updateFields.push("mo_ta = ?");
        values.push(bookData.description);
      }

      if (bookData.price) {
        updateFields.push("gia = ?");
        values.push(bookData.price);
      }

      if (bookData.imageUrl !== undefined) {
        updateFields.push("url_anh = ?");
        values.push(
          bookData.imageUrl ||
            "https://res.cloudinary.com/dyxy8asve/image/upload/v1746379642/dacnhantam86_vgjoyu.jpg"
        );
      }

      if (bookData.category) {
        updateFields.push("ma_danh_muc = ?");
        values.push(bookData.category);
      }

      if (bookData.publisherId) {
        updateFields.push("ma_nha_xuat_ban = ?");
        values.push(bookData.publisherId);
      }

      if (bookData.quantity) {
        updateFields.push("so_luong = ?");
        values.push(bookData.quantity);
      }

      if (bookData.seriesId !== undefined) {
        updateFields.push("series_id = ?");
        values.push(bookData.seriesId);
      }

      // Always update the timestamp when updating a record
      updateFields.push("ngay_cap_nhat = NOW()");

      // If no fields to update, return
      if (updateFields.length === 0) {
        console.log("No fields to update");
        return 0;
      }

      // Add the WHERE clause value at the end
      values.push(id);

      const query = `UPDATE books SET ${updateFields.join(
        ", "
      )} WHERE ma_sach = ? AND is_deleted = 1`;
      console.log("Update query:", query);
      console.log("Update values:", values);

      [result] = await db.query(query, values);
      console.log("Update result:", result);
      return result.affectedRows;
    } catch (error) {
      console.error("Error in updateBook:", error);
      throw error;
    }
  }

  static async deleteBook(id) {
    try {
      console.log(`Soft deleting book with ID ${id}`);
      // Instead of actually deleting the record, we set is_deleted to 0
      const [result] = await db.query(
        "UPDATE books SET is_deleted = 0, ngay_cap_nhat = NOW() WHERE ma_sach = ? AND is_deleted = 1",
        [id]
      );
      return result.affectedRows;
    } catch (error) {
      console.error("Error in deleteBook:", error);
      throw error;
    }
  }

  // Add a method to hard delete a book if needed
  static async hardDeleteBook(id) {
    try {
      console.log(`Hard deleting book with ID ${id}`);
      const [result] = await db.query("DELETE FROM books WHERE ma_sach = ?", [
        id,
      ]);
      return result.affectedRows;
    } catch (error) {
      console.error("Error in hardDeleteBook:", error);
      throw error;
    }
  }

  // Optional: Add a method to restore deleted books
  static async restoreBook(id) {
    try {
      console.log(`Restoring deleted book with ID ${id}`);
      const [result] = await db.query(
        "UPDATE books SET is_deleted = 1, ngay_cap_nhat = NOW() WHERE ma_sach = ? AND is_deleted = 0",
        [id]
      );
      return result.affectedRows;
    } catch (error) {
      console.error("Error in restoreBook:", error);
      throw error;
    }
  }
}

module.exports = BookModel;
