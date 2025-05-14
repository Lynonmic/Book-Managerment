import 'dart:io';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/api_service.dart';

class BookRepository {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];

  List<Book> get books => _filteredBooks.isNotEmpty ? _filteredBooks : _books;

  // Get all books
  Future<List<Book>> getBooks() async {
    try {
      _books = await ApiService.getAllBooks();
      return books;
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  // Refresh books
  Future<List<Book>> refreshBooks() async {
    return getBooks();
  }

  // Get book by ID
  Future<Book> getBookById(int id) async {
    try {
      return await ApiService.getBookById(id);
    } catch (e) {
      throw Exception('Failed to fetch book: $e');
    }
  }

Future<Book?> createBook(Book book) async {
  try {
    final createdBook = await ApiService.createBook(book);
    if (createdBook != null) {
      _books.add(createdBook); // Update the in-memory book list
      return createdBook; // Return the created book
    } else {
      print("Warning: Create book response did not return a Book object.");
      return null;
    }
  } catch (e) {
    print("Error creating book: $e");
    throw Exception('Failed to create book: $e');
  }
}

  // Update an existing book
  Future<Book> updateBook(Book book) async {
    try {
      final response = await ApiService.updateBook(book.id!, book);
      if (response['success']) {
        // Get the updated book from the server
        final updatedBook = await getBookById(book.id!);
        // Update the local cache
        final index = _books.indexWhere((b) => b.id == book.id);
        if (index != -1) {
          _books[index] = updatedBook;
        }
        return updatedBook;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // Delete a book
  Future<bool> deleteBook(int bookId) async {
    try {
      final response = await ApiService.deleteBook(bookId);
      if (response['success']) {
        _books.removeWhere((book) => book.id == bookId);
        return true;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Rate a book
  Future<bool> rateBook(int bookId, double rating) async {
    try {
      final response = await ApiService.rateBook(bookId, rating);
      return response['success'];
    } catch (e) {
      throw Exception('Failed to rate book: $e');
    }
  }

  // Filter books by category
  List<Book> filterByCategory(String categoryName) {
    _filteredBooks =
        _books.where((book) => book.category == categoryName).toList();
    return _filteredBooks;
  }

  // Clear filters
  void clearFilters() {
    _filteredBooks = [];
  }

  // Search books by title or author
  List<Book> searchBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = [];
      return _books;
    }

    final lowercaseQuery = query.toLowerCase();
    _filteredBooks =
        _books.where((book) {
          return book.title.toLowerCase().contains(lowercaseQuery) ||
              (book.author?.toLowerCase().contains(lowercaseQuery) ?? false);
        }).toList();

    return _filteredBooks;
  }

  // Upload book image to Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await ApiService.uploadImage(imageFile);
      if (response['success']) {
        return response['imageUrl'];
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
