import 'package:flutter/foundation.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_services.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books => _filteredBooks.isEmpty ? _books : _filteredBooks;

  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  final BookService _bookService = BookService();

  Future<void> fetchBooks({bool isRetry = false}) async {
    _isLoading = true;
    if (!isRetry) {
      _filteredBooks = [];
    }
    _error = '';
    notifyListeners();

    try {
      _books = await _bookService.fetchBooks();
      print("===== _fetchUsers() got ${_books.length} users =====");
      for (var book in _books) {
        print(book.title);
      }
      final fetchedBooks = await _bookService.fetchBooks();
      _books = fetchedBooks;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch books: $e';
      notifyListeners();
    }
  }

  Future<void> refreshBooks() async {
    _filteredBooks = [];
    return fetchBooks();
  }

  Future<Book?> updateBook(Book book) async {
    try {
      final updatedBook = await _bookService.updateBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = updatedBook;
        notifyListeners();
      }
      return updatedBook;
    } catch (e) {
      _error = 'Failed to update book: $e';
      notifyListeners();
      return null;
    }
  }

  Future<Book?> addBook(Book book) async {
    try {
      final newBook = await _bookService.createBook(book);
      _books.add(newBook);
      notifyListeners();
      return newBook;
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> rateBook(int bookId, double rating) async {
    try {
      await _bookService.rateBook(bookId, rating);
      // Update the local book's rating
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to rate book: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
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

      return true;
    } catch (e) {
      _error = 'Error deleting book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void filterByCategory(int categoryId) {
    _filteredBooks =
        _books.where((book) => book.category == categoryId).toList();
    notifyListeners();
  }
}
