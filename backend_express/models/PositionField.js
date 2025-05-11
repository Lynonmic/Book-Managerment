const db = require("../config/database");

const PositionFieldModel = {
  // Lấy tất cả các trường vị trí
  getAllPositionFields: async () => {
    try {
      const [rows] = await db.query(`SELECT id, name FROM position_fields`);
      console.log("Fetched rows:", rows);
      return rows;
    } catch (error) {
      console.error("DB query error in getAllPositionFields:", error.message);
      throw error;
    }
  },

  // Thêm trường vị trí
  addPositionField: async (name) => {
    try {
      const [result] = await db.query(
        `INSERT INTO position_fields (name) VALUES (?)`,
        [name]
      );
      return result.insertId;
    } catch (error) {
      throw error;
    }
  },

  // Lấy thông tin trường vị trí theo ID
  getPositionFieldById: async (id) => {
    try {
      const [rows] = await db.query(
        `SELECT id, name FROM position_fields WHERE id = ?`,
        [id]
      );
      return rows[0]; // Chỉ trả về đối tượng đầu tiên
    } catch (error) {
      throw error;
    }
  },

  // Cập nhật tên trường vị trí
  updatePositionField: async (id, name) => {
    try {
      const [result] = await db.query(
        "UPDATE position_fields SET name = ? WHERE id = ?",
        [name, id]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },

  // Xóa trường vị trí
  removePositionField: async (id) => {
    try {
      const [result] = await db.query(
        "DELETE FROM position_fields WHERE id = ?",
        [id]
      );
      return result.affectedRows;
    } catch (error) {
      throw error;
    }
  },
  // Lấy thông tin trường vị trí theo tên
  getPositionFieldByName: async (name) => {
    try {
      const [rows] = await db.query(
        `SELECT id, name FROM position_fields WHERE name = ?`,
        [name]
      );
      return rows[0]; // Trả về đối tượng đầu tiên nếu tìm thấy
    } catch (error) {
      throw error;
    }
  },
};

module.exports = PositionFieldModel;
