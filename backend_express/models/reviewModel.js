const db = require('../config/database');

// Get all reviews
exports.getAllReviews = async () => {
  try {
    const [rows] = await db.query(`
      SELECT r.ma_danh_gia as id, r.ma_sach as bookId, 
             r.ma_khach_hang as customerId, r.diem_danh_gia as rating, 
             r.binh_luan as comment, r.ngay_tao as createdAt,
             b.ten_sach as bookTitle, u.ten_khach_hang as customerName
      FROM reviews r
      LEFT JOIN books b ON r.ma_sach = b.ma_sach
      LEFT JOIN users u ON r.ma_khach_hang = u.ma_khach_hang
      ORDER BY r.ngay_tao DESC
    `);
    return rows;
  } catch (error) {
    console.error('Error getting all reviews:', error);
    throw error;
  }
};

// Get reviews by book ID
exports.getReviewsByBookId = async (bookId) => {
  try {
    const [rows] = await db.query(`
      SELECT r.ma_danh_gia as id, r.ma_sach as bookId, 
             r.ma_khach_hang as customerId, r.diem_danh_gia as rating, 
             r.binh_luan as comment, r.ngay_tao as createdAt,
             b.ten_sach as bookTitle, u.ten_khach_hang as customerName
      FROM reviews r
      LEFT JOIN books b ON r.ma_sach = b.ma_sach
      LEFT JOIN users u ON r.ma_khach_hang = u.ma_khach_hang
      WHERE r.ma_sach = ?
      ORDER BY r.ngay_tao DESC
    `, [bookId]);
    return rows;
  } catch (error) {
    console.error('Error getting reviews by book ID:', error);
    throw error;
  }
};

// Get reviews by customer ID
exports.getReviewsByCustomerId = async (customerId) => {
  try {
    const [rows] = await db.query(`
      SELECT r.ma_danh_gia as id, r.ma_sach as bookId, 
             r.ma_khach_hang as customerId, r.diem_danh_gia as rating, 
             r.binh_luan as comment, r.ngay_tao as createdAt,
             b.ten_sach as bookTitle, u.ten_khach_hang as customerName
      FROM reviews r
      LEFT JOIN books b ON r.ma_sach = b.ma_sach
      LEFT JOIN users u ON r.ma_khach_hang = u.ma_khach_hang
      WHERE r.ma_khach_hang = ?
      ORDER BY r.ngay_tao DESC
    `, [customerId]);
    return rows;
  } catch (error) {
    console.error('Error getting reviews by customer ID:', error);
    throw error;
  }
};

// Get a specific review by ID
exports.getReviewById = async (id) => {
  try {
    const [rows] = await db.query(`
      SELECT r.ma_danh_gia as id, r.ma_sach as bookId, 
             r.ma_khach_hang as customerId, r.diem_danh_gia as rating, 
             r.binh_luan as comment, r.ngay_tao as createdAt,
             b.ten_sach as bookTitle, u.ten_khach_hang as customerName
      FROM reviews r
      LEFT JOIN books b ON r.ma_sach = b.ma_sach
      LEFT JOIN users u ON r.ma_khach_hang = u.ma_khach_hang
      WHERE r.ma_danh_gia = ?
    `, [id]);
    
    return rows.length ? rows[0] : null;
  } catch (error) {
    console.error('Error getting review by ID:', error);
    throw error;
  }
};

// Create a new review
exports.createReview = async (reviewData) => {
  try {
    const { bookId, customerId, rating, comment } = reviewData;
    
    const [result] = await db.query(
      'INSERT INTO reviews (ma_sach, ma_khach_hang, diem_danh_gia, binh_luan, ngay_tao) VALUES (?, ?, ?, ?, NOW())',
      [bookId, customerId, rating, comment]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error creating review:', error);
    throw error;
  }
};

// Update an existing review
exports.updateReview = async (id, reviewData) => {
  try {
    const { rating, comment } = reviewData;
    
    const [result] = await db.query(
      'UPDATE reviews SET diem_danh_gia = ?, binh_luan = ? WHERE ma_danh_gia = ?',
      [rating, comment, id]
    );
    
    return result.affectedRows;
  } catch (error) {
    console.error('Error updating review:', error);
    throw error;
  }
};

// Delete a review
exports.deleteReview = async (id) => {
  try {
    const [result] = await db.query('DELETE FROM reviews WHERE ma_danh_gia = ?', [id]);
    return result.affectedRows;
  } catch (error) {
    console.error('Error deleting review:', error);
    throw error;
  }
};

// Get average rating for a book
exports.getBookAverageRating = async (bookId) => {
  try {
    const [rows] = await db.query(
      'SELECT AVG(diem_danh_gia) as averageRating, COUNT(*) as totalReviews FROM reviews WHERE ma_sach = ?',
      [bookId]
    );
    
    return {
      averageRating: rows[0].averageRating || 0,
      totalReviews: rows[0].totalReviews || 0
    };
  } catch (error) {
    console.error('Error getting book average rating:', error);
    throw error;
  }
};
