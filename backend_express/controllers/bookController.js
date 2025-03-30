const BookModel = require("../models/bookModel");

// Utility function to convert snake_case database fields to camelCase
const formatBookResponse = (book) => {
  if (!book) return null;

  return {
    id: book.ma_sach || book.id,
    title: book.ten_sach || book.title,
    author: book.tac_gia || book.author,
    description: book.mo_ta || book.description,
    imageUrl: book.url_anh || book.image_url,
    price: book.gia || book.price,
    publisher: book.ma_nha_xuat_ban || book.publisher,
    quantity: book.so_luong || book.quantity,
    createdAt: book.ngay_tao || book.created_at,
    updatedAt: book.ngay_cap_nhat || book.updated_at,
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
    const bookId = await BookModel.createBook(req.body);
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
    const affected = await BookModel.updateBook(req.params.id, req.body);
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

exports.searchBooks = async (req, res) => {
  try {
    const query = req.query.query;
    if (!query) {
      return res
        .status(400)
        .json({ success: false, message: "Missing search query" });
    }

    console.log(`📩 Received search request: "${query}"`);

    const books = await BookModel.searchBooks(query);

    console.log(`✅ Found ${books.length} books`);
    res.status(200).json({ success: true, data: books });
  } catch (error) {
    console.error("❌ Search API error:", error);
    res
      .status(500)
      .json({ success: false, message: "Search failed", error: error.message });
  }
};
