const db = require('../config/database');
const PositionField = require("../models/PositionField");
const BookPosition = require("../models/BookPosition");
const Book = require("../models/bookModel");

// Lấy tất cả các trường vị trí
const getAllPositionFields = async (req, res) => {
  try {
    const positionFields = await PositionField.getAllPositionFields();
    res.json(positionFields);
  } catch (error) {
    res.status(500).json({ message: "Lỗi khi lấy trường vị trí", error });
  }
};

const addPositionField = async (req, res) => {
  const { name } = req.body; // Nhận tên vị trí từ client

  try {
    // Kiểm tra xem tên vị trí đã tồn tại chưa
    const existingPositionField = await PositionField.getAllPositionFields(); // Check all position fields
    const isExisting = existingPositionField.some(
      (field) => field.name === name
    );

    if (isExisting) {
      return res.status(400).json({ message: "Vị trí này đã tồn tại" });
    }

    // Tạo mới trường vị trí
    const newPositionFieldId = await PositionField.addPositionField(name);
    res.status(201).json({ id: newPositionFieldId, name });
  } catch (error) {
    console.error("Error occurred while adding position field:", error); // Log error details
    res
      .status(500)
      .json({ message: "Lỗi khi thêm trường vị trí", error: error.message });
  }
};

// Thêm vị trí cho sách
const addBookPosition = async (req, res) => {
  const { ma_sach, position_field_id, position_value } = req.body;

  try {
    const result = await BookPosition.addBookPosition(
      ma_sach,
      position_field_id,
      position_value
    );

    res.status(201).json({
      message: "Thêm hoặc cập nhật vị trí sách thành công",
      result,
    });
  } catch (error) {
    console.error("Lỗi khi thêm vị trí sách:", error);
    res
      .status(500)
      .json({ message: "Lỗi khi thêm vị trí sách", error: error.message });
  }
};

// Lấy các vị trí của một cuốn sách
const getBookPositions = async (req, res) => {
  const { bookId } = req.params;

  try {
    const bookPositions = await BookPosition.getBookPositions(bookId);

    if (!bookPositions || bookPositions.length === 0) {
      return res.status(404).json({ message: "Không có vị trí sách nào" });
    }

    res.json(bookPositions);
  } catch (error) {
    console.error("Lỗi khi lấy vị trí sách:", error);
    res
      .status(500)
      .json({ message: "Lỗi khi lấy vị trí sách", error: error.message });
  }
};

// Cập nhật tên trường vị trí
const updatePositionField = async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  try {
    const updated = await PositionField.updatePositionField(id, name);
    if (updated === 0) {
      return res
        .status(404)
        .json({ message: "Không tìm thấy trường vị trí để cập nhật" });
    }
    res.json({ message: "Cập nhật thành công" });
  } catch (error) {
    res.status(500).json({
      message: "Lỗi khi cập nhật trường vị trí",
      error: error.message,
    });
  }
};

// Xóa trường vị trí
const deletePositionField = async (req, res) => {
  const { id } = req.params;

  try {
    // Kiểm tra ID có hợp lệ không
    if (!id || isNaN(id)) {
      return res.status(400).json({ message: "ID không hợp lệ" });
    }

    // Kiểm tra xem có sách nào đang sử dụng trường vị trí này không
    const [booksUsingField] = await db.query(
      "SELECT 1 FROM book_positions WHERE position_field_id = ? LIMIT 1",
      [id]
    );

    if (booksUsingField.length > 0) {
      return res.status(400).json({
        message: "Không thể xóa vì có sách đang sử dụng trường vị trí này",
      });
    }

    // Tiến hành xóa nếu không bị ràng buộc
    const deleted = await PositionField.removePositionField(id);

    if (deleted === 0) {
      return res
        .status(404)
        .json({ message: "Không tìm thấy trường vị trí để xóa" });
    }

    res.json({ message: "Đã xóa trường vị trí thành công" });
  } catch (error) {
    console.error("Lỗi khi xóa trường vị trí:", error);
    res.status(500).json({
      message: "Lỗi khi xóa trường vị trí",
      error: error.message,
    });
  }
};


const removeBookPosition = async (req, res) => {
  const { bookId, positionFieldId } = req.params;

  try {
    const book = await Book.findByPk(bookId);
    if (!book) {
      return res.status(404).json({ message: "Sách không tồn tại" });
    }

    const deleted = await BookPosition.removeBookPosition(
      bookId,
      positionFieldId
    );
    if (deleted === 0) {
      return res.status(404).json({ message: "Vị trí sách không tồn tại" });
    }

    res.json({ message: "Đã xóa vị trí sách thành công" });
  } catch (error) {
    res.status(500).json({ message: "Lỗi khi xóa vị trí sách", error });
  }
};

// Xóa tất cả các vị trí của một cuốn sách
const clearBookPositions = async (req, res) => {
  const { bookId } = req.params;

  try {
    const book = await Book.findByPk(bookId);
    if (!book) {
      return res.status(404).json({ message: "Sách không tồn tại" });
    }

    const deleted = await BookPosition.clearBookPositions(bookId);
    if (deleted === 0) {
      return res.status(404).json({ message: "Không có vị trí sách để xóa" });
    }

    res.json({ message: "Đã xóa tất cả vị trí sách thành công" });
  } catch (error) {
    res.status(500).json({ message: "Lỗi khi xóa tất cả vị trí sách", error });
  }
};

// Cập nhật giá trị vị trí sách
const updateBookPosition = async (req, res) => {
  const { bookId, positionFieldId } = req.params;
  const { positionValue } = req.body;

  try {
    const updated = await BookPosition.addBookPosition(
      bookId,
      positionFieldId,
      positionValue
    );
    if (updated === 0) {
      return res
        .status(404)
        .json({ message: "Vị trí sách không tồn tại để cập nhật" });
    }
    res.json({ message: "Cập nhật vị trí sách thành công" });
  } catch (error) {
    res.status(500).json({ message: "Lỗi khi cập nhật vị trí sách", error });
  }
};

// Lấy tất cả sách theo một trường vị trí
const getBookPositionsByField = async (req, res) => {
  const { positionFieldId } = req.params;

  try {
    const booksWithPosition = await BookPosition.getBooksByPositionField(
      positionFieldId
    );

    if (!booksWithPosition || booksWithPosition.length === 0) {
      return res
        .status(404)
        .json({ message: "Không có sách nào với trường vị trí này" });
    }

    res.json(booksWithPosition);
  } catch (error) {
    console.error("Lỗi khi lấy sách theo trường vị trí:", error);
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
};

module.exports = {
  getAllPositionFields,
  addBookPosition,
  addPositionField,
  getBookPositions,
  updatePositionField,
  deletePositionField,
  removeBookPosition,
  clearBookPositions,
  updateBookPosition,
  getBookPositionsByField,
};
