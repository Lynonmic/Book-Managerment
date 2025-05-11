const PositionField = require('../models/PositionField');
const BookPosition = require('../models/BookPosition');
const Book = require('../models/bookModel');

// Lấy tất cả các trường vị trí
const getAllPositionFields = async (req, res) => {
  try {
    const positionFields = await PositionField.getAllPositionFields();
    res.json(positionFields);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy trường vị trí', error });
  }
};

const addPositionField = async (req, res) => {
  const { name } = req.body; // Nhận tên vị trí từ client

  try {
    // Kiểm tra xem tên vị trí đã tồn tại chưa
    const existingPositionField = await PositionField.getAllPositionFields(); // Check all position fields
    const isExisting = existingPositionField.some(field => field.name === name);

    if (isExisting) {
      return res.status(400).json({ message: 'Vị trí này đã tồn tại' });
    }

    // Tạo mới trường vị trí
    const newPositionFieldId = await PositionField.addPositionField(name);
    res.status(201).json({ id: newPositionFieldId, name });
  } catch (error) {
    console.error('Error occurred while adding position field:', error); // Log error details
    res.status(500).json({ message: 'Lỗi khi thêm trường vị trí', error: error.message });
  }
};

// Thêm vị trí cho sách
const addBookPosition = async (req, res) => {
  const { bookId, positionFieldId, positionValue } = req.body;

  try {
    const book = await Book.findByPk(bookId);
    if (!book) {
      return res.status(404).json({ message: 'Sách không tồn tại' });
    }

    const bookPosition = await BookPosition.create({
      bookId,
      positionFieldId,
      positionValue
    });

    res.status(201).json(bookPosition);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi thêm vị trí sách', error });
  }
};

// Lấy các vị trí của một cuốn sách
const getBookPositions = async (req, res) => {
  const { bookId } = req.params;

  try {
    const bookPositions = await BookPosition.findAll({
      where: { bookId },
      include: [PositionField]
    });

    res.json(bookPositions);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy vị trí sách', error });
  }
};

module.exports = {
  getAllPositionFields,
  addBookPosition,
  addPositionField,
  getBookPositions
};
