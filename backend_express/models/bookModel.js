const db = require("../config/database");
class BookModel {
  static async getAllBooks() {
    try {
      const [rows] = await db.query(`
        SELECT 
          b.ma_sach as id,
          b.ten_sach as title,
          b.tac_gia as author,
          b.mo_ta as description,
          b.url_anh as image_url,
          b.gia as price,
          b.ma_nha_xuat_ban as publisher_id,
          b.so_luong as quantity,
          b.series_id,
          b.ngay_tao as created_at,
          b.ngay_cap_nhat as updated_at,
          bl.ma_ke as shelf,
          bl.ma_kho as warehouse,
          bl.vi_tri as position
        FROM books b
        LEFT JOIN book_locations bl ON b.ma_sach = bl.ma_sach AND bl.is_deleted = 1
        WHERE b.is_deleted = 1
      `);
      return rows;
    } catch (error) {
      throw error;
    }
  }

  static async getBookById(id) {
    try {
      const [rows] = await db.query(
        `
        SELECT 
          b.*,
          bl.ma_ke as shelf,
          bl.ma_kho as warehouse,
          bl.vi_tri as position
        FROM books b
        LEFT JOIN book_locations bl ON b.ma_sach = bl.ma_sach AND bl.is_deleted = 1
        WHERE b.ma_sach = ? AND b.is_deleted = 1
      `,
        [id]
      );
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async createBook(bookData) {
    try {
      if (!bookData.title || !bookData.imageUrl || !bookData.price) {
        throw new Error("Missing required fields: title, imageUrl, or price");
      }

      const connection = await db.getConnection();
      try {
        await connection.beginTransaction();

        // Insert book
        const [bookResult] = await connection.query(
          `INSERT INTO books (ten_sach, url_anh, tac_gia, ma_danh_muc, ma_nha_xuat_ban, gia, so_luong, mo_ta, series_id, is_deleted) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
          [
            bookData.title,
            bookData.imageUrl,
            bookData.author || null,
            bookData.category || null,
            bookData.publisherId || null,
            bookData.price,
            bookData.quantity || 0,
            bookData.description || null,
            bookData.seriesId || null,
          ]
        );

        const bookId = bookResult.insertId;

        // Insert book location if provided
        if (bookData.shelf && bookData.warehouse && bookData.position) {
          await connection.query(
            `INSERT INTO book_locations (ma_sach, ma_ke, ma_kho, vi_tri, is_deleted)
             VALUES (?, ?, ?, ?, 1)`,
            [bookId, bookData.shelf, bookData.warehouse, bookData.position]
          );
        }

        await connection.commit();
        return bookId;
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error("Error in createBook:", error);
      throw error;
    }
  }

  static async updateBook(id, bookData) {
    try {
      const connection = await db.getConnection();
      try {
        await connection.beginTransaction();

        // Update book
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

        if (bookData.imageUrl) {
          updateFields.push("url_anh = ?");
          values.push(bookData.imageUrl);
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
        if (updateFields.length > 0) {
          values.push(id);
          await connection.query(
            `UPDATE books SET ${updateFields.join(", ")}, ngay_cap_nhat = NOW() 
           WHERE ma_sach = ? AND is_deleted = 1`,
            values
          );
        }

        // Update book location if provided
        if (bookData.shelf || bookData.warehouse || bookData.position) {
          const [existingLocation] = await connection.query(
            "SELECT id FROM book_locations WHERE ma_sach = ? AND is_deleted = 1",
            [id]
          );

          if (existingLocation.length > 0) {
            // Update existing location
            await connection.query(
              `UPDATE book_locations 
             SET ma_ke = COALESCE(?, ma_ke),
                 ma_kho = COALESCE(?, ma_kho),
                 vi_tri = COALESCE(?, vi_tri)
             WHERE ma_sach = ? AND is_deleted = 1`,
              [bookData.shelf, bookData.warehouse, bookData.position, id]
            );
          } else {
            // Insert new location
            await connection.query(
              `INSERT INTO book_locations (ma_sach, ma_ke, ma_kho, vi_tri, is_deleted)
             VALUES (?, ?, ?, ?, 1)`,
              [id, bookData.shelf, bookData.warehouse, bookData.position]
            );
          }
        }

        await connection.commit();
        return true;
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
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
