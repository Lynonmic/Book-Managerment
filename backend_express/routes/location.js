const express = require('express');
const router = express.Router();
const {
  getAllPositionFields,
  addBookPosition,
  addPositionField,
  getBookPositions,
  updatePositionField,
  deletePositionField,
  removeBookPosition,
  clearBookPositions,
  updateBookPosition
} = require('../controllers/Location');

// ===== VỊ TRÍ TRƯỜNG (Position Fields) ===== //
router.get('/position-fields', getAllPositionFields);             // Lấy tất cả trường vị trí
router.post('/position-fields', addPositionField);                // Thêm trường vị trí
router.put('/position-fields/:id', updatePositionField);          // Cập nhật tên trường vị trí
router.delete('/position-fields/:id', deletePositionField);       // Xóa trường vị trí

// ===== VỊ TRÍ SÁCH (Book Positions) ===== //
router.post('/book-positions', addBookPosition);                  // Thêm hoặc cập nhật vị trí sách
router.get('/book-positions/:bookId', getBookPositions);          // Lấy tất cả vị trí của một cuốn sách
router.put('/book-positions/:bookId/:positionFieldId', updateBookPosition);  // Cập nhật vị trí sách
router.delete('/book-positions/:bookId/:positionFieldId', removeBookPosition); // Xóa 1 vị trí sách
router.delete('/book-positions/:bookId', clearBookPositions);     // Xóa tất cả vị trí của sách

module.exports = router;
