const db = require("../config/database");

const BookPositionModel = {
  // Lấy tất cả các vị trí của sách
  getBookPositions: async (bookId) => {
    try {
      const [rows] = await db.query(`
        SELECT 
          bp.id,
          bp.bookId,
          bp.positionFieldId,
          bp.positionValue,
          pf.name AS positionName
        FROM book_positions bp
        JOIN position_fields pf ON bp.positionFieldId = pf.id
        WHERE bp.bookId = ?
      `, [bookId]);
      return rows;
    } catch (error) {
      throw error;
    }
  },

  // Thêm vị trí cho sách
  addBookPosition: async (bookId, positionFieldId, positionValue) => {
    try {
      // Kiểm tra xem vị trí này đã tồn tại chưa
      const [existingPosition] = await db.query(
        'SELECT * FROM book_positions WHERE bookId = ? AND positionFieldId = ?',
        [bookId, positionFieldId]
      );

      if (existingPosition.length > 0) {
        // Nếu vị trí đã tồn tại, chỉ cần cập nhật
        const [result] = await db.query(
          'UPDATE book_positions SET positionValue = ? WHERE bookId = ? AND positionFieldId = ?',
          [positionValue, bookId, positionFieldId]
        );
        return result.affectedRows;
      } else {
        // Nếu không có, tạo mới vị trí cho sách
        const [result] = await db.query(
          `INSERT INTO book_positions (bookId, positionFieldId, positionValue) 
           VALUES (?, ?, ?)`,
          [bookId, positionFieldId, positionValue]
        );
        return result.insertId;
      }
    } catch (error) {
      throw error;
    }
  },

  // Xóa vị trí sách
  removeBookPosition: async (bookId, positionFieldId) => {
    try {
      const [result] = await db.query(
        'DELETE FROM book_positions WHERE bookId = ? AND positionFieldId = ?',
        [bookId, positionFieldId]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },

  // Xóa tất cả các vị trí của sách
  clearBookPositions: async (bookId) => {
    try {
      const [result] = await db.query(
        'DELETE FROM book_positions WHERE bookId = ?',
        [bookId]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }
};

module.exports = BookPositionModel;
