const express = require('express');
const router = express.Router();
const Book = require('../models/bookModel');
const db = require('../config/database'); // Assuming you have a database connection file

// Get all books
router.get('/', async (req, res) => {
  try {
    const books = await Book.getAllBooks();
    res.json(books);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch books' });
  }
});

// Get a single book by ID
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.getBookById(req.params.id);
    if (!book) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }
    res.json(book);
  } catch (error) {
    console.error('Error fetching book:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch book' });
  }
});

// Create a new book
router.post('/', async (req, res) => {
  const { title, author, description, imageUrl, price, publisherId } = req.body;

  const newBookData = {
    title,
    author,
    description,
    imageUrl,
    price,
    publisherId
  };

  try {
    const newBookId = await Book.createBook(newBookData);
    res.status(201).json({ success: true, message: 'Book added successfully', bookId: newBookId });
  } catch (error) {
    console.error('Error adding book:', error);
    res.status(500).json({ success: false, message: 'Failed to add book' });
  }
});

// Update a book
router.put('/:id', async (req, res) => {
  const bookId = req.params.id;
  console.log(`Received update request for book ID: ${bookId}`);
  console.log('Request body:', req.body);
  
  // Map request body to the expected fields in the database
  const bookData = {
    title: req.body.title,
    author: req.body.author,
    description: req.body.description,
    imageUrl: req.body.url_anh || req.body.imageUrl, // Accept either name
    price: req.body.price,
    publisherId: req.body.ma_nha_xuat_ban || req.body.publisherId, // Accept either name
    category: req.body.category,
    rating: req.body.rating
  };
  
  try {
    // Convert the bookId to an integer explicitly
    const numericId = parseInt(bookId, 10);
    console.log(`Parsed numeric ID: ${numericId}`);
    
    // Pass the mapped data to updateBook
    const affectedRows = await Book.updateBook(numericId, bookData);
    
    if (affectedRows === 0) {
      console.log(`Book with ID ${numericId} not found or no changes made`);
      return res.status(404).json({ 
        success: false, 
        message: 'Book not found or no changes made' 
      });
    }
    
    console.log(`Successfully updated book with ID ${numericId}`);
    res.json({ success: true, message: 'Book updated successfully' });
  } catch (error) {
    console.error('Error updating book:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update book', 
      error: error.message 
    });
  }
});

// Delete a book
router.delete('/:id', async (req, res) => {
  const bookId = req.params.id;
  
  try {
    const affectedRows = await Book.deleteBook(bookId);
    
    if (affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }
    
    res.json({ success: true, message: 'Book deleted successfully' });
  } catch (error) {
    console.error('Error deleting book:', error);
    res.status(500).json({ success: false, message: 'Failed to delete book', error: error.message });
  }
});

// Rate a book
router.post('/:id/rate', async (req, res) => {
  const bookId = req.params.id;
  const { rating } = req.body;
  
  // Implement the rating functionality in your book model
  // For now, just return a success response
  res.json({ success: true, message: 'Book rated successfully' });
});

// Get table schema
router.get('/schema', async (req, res) => {
  try {
    const [rows] = await db.query('DESCRIBE books');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching schema:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch schema' });
  }
});

// List first 10 records with all columns
router.get('/debug', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM books LIMIT 10');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching debug data:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch debug data' });
  }
});

module.exports = router;