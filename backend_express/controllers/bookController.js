const BookModel = require("../models/bookModel");

const formatBookResponse = (book) => {
  if (!book) return null;

  return {
    id: book.ma_sach,
    title: book.ten_sach,
    author: book.tac_gia,
    description: book.mo_ta,
    imageUrl: book.url_anh,
    price: book.gia,
    publisherId: book.ma_nha_xuat_ban,
    quantity: book.so_luong,
    category: book.ma_danh_muc,
    seriesId: book.series_id,
    createdAt: book.ngay_tao,
    updatedAt: book.ngay_cap_nhat,
  };
};

// Get all books
exports.getAllBooks = async (req, res) => {
  try {
    const books = await BookModel.getAllBooks();
    res.status(200).json({
      success: true,
      data: books.map((book) => formatBookResponse(book)),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch books",
      error: error.message,
    });
  }
};

// Get a single book by ID
exports.getBookById = async (req, res) => {
  try {
    const book = await BookModel.getBookById(req.params.id);
    if (!book) {
      return res.status(404).json({
        success: false,
        message: "Book not found",
      });
    }
    res.status(200).json({
      success: true,
      data: formatBookResponse(book),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch book",
      error: error.message,
    });
  }
};

// Create a new book
exports.createBook = async (req, res) => {
  try {
    const bookData = {
      title: req.body.title,
      imageUrl: req.body.imageUrl,
      price: req.body.price,
      author: req.body.author,
      category: req.body.category,
      publisherId: req.body.publisherId,
      quantity: req.body.quantity,
      description: req.body.description,
      seriesId: req.body.seriesId,
    };

    const bookId = await BookModel.createBook(bookData);
    res.status(201).json({
      success: true,
      message: "Book created successfully",
      data: { id: bookId },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to create book",
      error: error.message,
    });
  }
};

// Update a book
exports.updateBook = async (req, res) => {
  try {
    const bookData = {
      title: req.body.title,
      imageUrl: req.body.imageUrl,
      price: req.body.price,
      author: req.body.author,
      category: req.body.category,
      publisherId: req.body.publisherId,
      quantity: req.body.quantity,
      description: req.body.description,
      seriesId: req.body.seriesId,
    };

    const affected = await BookModel.updateBook(req.params.id, bookData);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: "Book not found or no changes made",
      });
    }
    res.status(200).json({
      success: true,
      message: "Book updated successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update book",
      error: error.message,
    });
  }
};

// Delete a book
exports.deleteBook = async (req, res) => {
  try {
    const affected = await BookModel.deleteBook(req.params.id);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: "Book not found",
      });
    }
    res.status(200).json({
      success: true,
      message: "Book deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to delete book",
      error: error.message,
    });
  }
};