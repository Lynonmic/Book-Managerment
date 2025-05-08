const db = require("../config/database");

class SeriesModel {
  static async getAllSeries() {
    try {
      const [rows] = await db.query(`
        SELECT 
          id,
          name
        FROM series
      `);
      return rows;
    } catch (error) {
      throw error;
    }
  }

  static async getSeriesById(id) {
    try {
      const [rows] = await db.query('SELECT * FROM series WHERE id = ?', [id]);
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async createSeries(seriesData) {
    try {
      // Validate required fields
      if (!seriesData.name) {
        throw new Error('Missing required field: name');
      }

      const [result] = await db.query(
        `INSERT INTO series (name) VALUES (?)`,
        [seriesData.name]
      );
      return result.insertId;
    } catch (error) {
      console.error('Error in createSeries:', error);
      throw error;
    }
  }

  static async updateSeries(id, seriesData) {
    try {
      // Query to check if the series exists first
      const [checkSeries] = await db.query('SELECT id FROM series WHERE id = ?', [id]);
      
      if (checkSeries.length === 0) {
        console.log(`Series with ID ${id} not found in database`);
        return 0; // Series not found
      }
      
      console.log(`Series with ID ${id} exists in database`);
      
      // Validate required fields
      if (!seriesData.name) {
        throw new Error('Missing required field: name');
      }
      
      const [result] = await db.query('UPDATE series SET name = ? WHERE id = ?', [seriesData.name, id]);
      console.log('Update result:', result);
      return result.affectedRows;
    } catch (error) {
      console.error('Error in updateSeries:', error);
      throw error;
    }
  }

  static async deleteSeries(id) {
    try {
      console.log(`Deleting series with ID ${id}`);
      const [result] = await db.query('DELETE FROM series WHERE id = ?', [id]);
      return result.affectedRows;
    } catch (error) {
      console.error('Error in deleteSeries:', error);
      throw error;
    }
  }
  
  static async getBooksInSeries(seriesId) {
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
        WHERE series_id = ? AND is_deleted = 1
      `, [seriesId]);
      return rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = SeriesModel;
