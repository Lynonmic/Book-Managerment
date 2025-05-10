const db = require('../config/db');

class BookLocation {
  constructor(ma_sach, ma_ke, ma_kho, vi_tri, is_deleted = 1) {
    this.ma_sach = ma_sach;
    this.ma_ke = ma_ke;
    this.ma_kho = ma_kho;
    this.vi_tri = vi_tri;
    this.is_deleted = is_deleted;
  }

  static async findAll() {
    const [rows] = await db.query('SELECT * FROM book_locations WHERE is_deleted = 1');
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.query('SELECT * FROM book_locations WHERE id = ? AND is_deleted = 1', [id]);
    return rows[0];
  }

  static async findByBookId(ma_sach) {
    const [rows] = await db.query('SELECT * FROM book_locations WHERE ma_sach = ? AND is_deleted = 1', [ma_sach]);
    return rows[0];
  }

  async save() {
    const [result] = await db.query(
      'INSERT INTO book_locations (ma_sach, ma_ke, ma_kho, vi_tri, is_deleted) VALUES (?, ?, ?, ?, ?)',
      [this.ma_sach, this.ma_ke, this.ma_kho, this.vi_tri, this.is_deleted]
    );
    return result.insertId;
  }

  static async update(id, data) {
    const [result] = await db.query(
      'UPDATE book_locations SET ma_ke = ?, ma_kho = ?, vi_tri = ? WHERE id = ? AND is_deleted = 1',
      [data.ma_ke, data.ma_kho, data.vi_tri, id]
    );
    return result.affectedRows > 0;
  }

  static async delete(id) {
    const [result] = await db.query(
      'UPDATE book_locations SET is_deleted = 0 WHERE id = ?',
      [id]
    );
    return result.affectedRows > 0;
  }
}

module.exports = BookLocation;