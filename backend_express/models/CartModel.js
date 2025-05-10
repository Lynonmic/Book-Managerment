const db = require("../config/database");

const CartModel = {
  getUserCart: async (userId) => {
    try {
      const [rows] = await db.query(`
        SELECT 
          c.id,
          c.ma_khach_hang as user_id,
          c.ma_sach as book_id,
          c.so_luong as quantity,
          c.ngay_them as date_added,
          b.ten_sach as book_title,
          b.tac_gia as book_author,
          b.gia as book_price,
          b.url_anh as image_url,
          b.mo_ta as book_description
        FROM cart c
        JOIN books b ON c.ma_sach = b.ma_sach
        WHERE c.ma_khach_hang = ?
      `, [userId]);
      return rows;
    } catch (error) {
      throw error;
    }
  },

  addToCart: async (cartData) => {
    try {
      const [existingItem] = await db.query(
        'SELECT * FROM cart WHERE ma_khach_hang = ? AND ma_sach = ?',
        [cartData.userId, cartData.bookId]
      );

      if (existingItem.length > 0) {
        const [result] = await db.query(
          'UPDATE cart SET so_luong = so_luong + ? WHERE id = ?',
          [cartData.quantity, existingItem[0].id]
        );
        return existingItem[0].id;
      } else {
        const [result] = await db.query(
          `INSERT INTO cart (ma_khach_hang, ma_sach, so_luong) 
           VALUES (?, ?, ?)`,
          [cartData.userId, cartData.bookId, cartData.quantity]
        );
        return result.insertId;
      }
    } catch (error) {
      throw error;
    }
  },

  updateCartItem: async (cartId, quantity) => {
    try {
      const [result] = await db.query(
        'UPDATE cart SET so_luong = ? WHERE id = ?',
        [quantity, cartId]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },

  removeFromCart: async (cartId) => {
    try {
      const [result] = await db.query(
        'DELETE FROM cart WHERE id = ?',
        [cartId]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },

  clearCart: async (userId) => {
    try {
      const [result] = await db.query(
        'DELETE FROM cart WHERE ma_khach_hang = ?',
        [userId]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }
};

module.exports = CartModel;