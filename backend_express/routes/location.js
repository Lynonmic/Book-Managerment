const express = require('express');
const router = express.Router();
const { getAllPositionFields, addBookPosition, addPositionField, getBookPositions } = require('../controllers/Location');

// Lấy tất cả các trường vị trí
router.get('/position-fields', getAllPositionFields);

// Thêm vị trí cho sách
router.post('/book-positions', addBookPosition);
router.post('/position-fields', addPositionField);

// Lấy các vị trí của sách theo ID
router.get('/book-positions/:bookId', getBookPositions);

module.exports = router;
