const db = require("../config/database");

const BookPositionModel = {
  // Lấy tất cả các vị trí của sách
  getBookPositions: async (ma_sach) => {
    try {
      const [rows] = await db.query(`
        SELECT 
          bp.id,
          bp.ma_sach ,
          bp.position_field_id,
          bp.position_value,
          pf.name AS positionName
        FROM book_positions bp
        JOIN position_fields pf ON bp.position_field_id = pf.id
        WHERE bp.ma_sach  = ?
      `, [ma_sach]);
      return rows;
    } catch (error) {
      throw error;
    }
  },

  // Thêm vị trí cho sách
  addBookPosition: async (ma_sach, position_field_id, position_value) => {
    try {
      // Kiểm tra xem vị trí này đã tồn tại chưa
      const [existingPosition] = await db.query(
        'SELECT * FROM book_positions WHERE ma_sach = ? AND position_field_id = ?',
        [ma_sach, position_field_id]
      );

      if (existingPosition.length > 0) {
        // Nếu vị trí đã tồn tại, chỉ cần cập nhật
        const [result] = await db.query(
          'UPDATE book_positions SET position_value = ? WHERE ma_sach  = ? AND position_field_id = ?',
          [position_value, ma_sach, position_field_id]
        );
        return result.affectedRows;
      } else {
        // Nếu không có, tạo mới vị trí cho sách
        const [result] = await db.query(
          `INSERT INTO book_positions (ma_sach , position_field_id, position_value) 
           VALUES (?, ?, ?)`,
          [ma_sach, position_field_id, position_value]
        );
        return result.insertId;
      }
    } catch (error) {
      throw error;
    }
  },

  // Xóa vị trí sách
  removeBookPosition: async (ma_sach, position_field_id) => {
    try {
      const [result] = await db.query(
        'DELETE FROM book_positions WHERE ma_sach  = ? AND position_field_id = ?',
        [ma_sach, position_field_id]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },

  // Xóa tất cả các vị trí của sách
  clearBookPositions: async (ma_sach) => {
    try {
      const [result] = await db.query(
        'DELETE FROM book_positions WHERE ma_sach  = ?',
        [ma_sach]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  }
};
// Lấy danh sách sách theo một trường vị trí cụ thể
getBooksByPositionField: async (position_field_id) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        bp.ma_sach,
        b.ten_sach,
        bp.position_value,
        pf.name AS position_field_name
      FROM book_positions bp
      JOIN books b ON bp.ma_sach = b.id
      JOIN position_fields pf ON bp.position_field_id = pf.id
      WHERE bp.position_field_id = ?
    `, [position_field_id]);
    return rows;
  } catch (error) {
    throw error;
  }
},

module.exports = BookPositionModel;
