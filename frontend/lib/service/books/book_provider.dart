import 'package:flutter/foundation.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_services.dart';

class BookProvider with ChangeNotifier {
  final _bookService = BookService();

  List<Book> _books = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch books from API
  Future<void> fetchBooks() async {
    print("===== _fetchUsers() is called =====");

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _books = await _bookService.fetchBooks();
      print("===== _fetchUsers() got ${_books.length} users =====");
      _books.forEach((book) => print(book.title));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh books (force fetch)
  Future<void> refreshBooks() async {
    return fetchBooks();
  }

  // Get book by ID from local cache
  Book? getBookById(int id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch book by ID from API
  Future<Book?> fetchBookById(int id) async {
    // Check cache first
    final cachedBook = getBookById(id);
    if (cachedBook != null) {
      return cachedBook;
    }

    // If not in cache, fetch from API
    try {
      return await _bookService.fetchBookById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Rate a book
  Future<void> rateBook(int bookId, double rating) async {
    try {
      final updatedBook = await _bookService.rateBook(bookId, rating);

      // Update book in local cache if it exists
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index != -1) {
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e; // Re-throw so UI can show error
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      // Set loading state
      _isLoading = true;
      notifyListeners();

      // Call your book service to update the book
      await _bookService.updateBook(book);

      // Refresh the book list
      await fetchBooks();
    } catch (e) {
      _error = 'Error updating book: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBook(int bookId) async {
    try {
      // Set loading state
      _isLoading = true;
      notifyListeners();

      // Call your book service to delete the book
      await _bookService.deleteBook(bookId);

      // Remove the book from the local list
      _books.removeWhere((book) => book.id == bookId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting book: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
