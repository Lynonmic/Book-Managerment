import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/book_model.dart';

class BookService {
  final String baseUrl = 'http://10.0.2.2:3000/api/books'; // Update with your API URL

  // Fetch all books
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  // Fetch a book by ID
  Future<Book> fetchBookById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to load book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching book: $e');
    }
  }

  // Create a new book
  Future<Book> createBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ten_sach': book.title,
          'tac_gia': book.author,
          'mo_ta': book.description,
          'url_anh': book.imageUrl,
          'gia': book.price,
          'ma_nha_xuat_ban': book.publisher,
          'so_luong': book.quantity,
        }),
      );

      print("Request payload: ${json.encode({
        'ten_sach': book.title,
        'tac_gia': book.author,
        'mo_ta': book.description,
        'url_anh': book.imageUrl,
        'gia': book.price,
        'ma_nha_xuat_ban': book.publisher,
        'so_luong': book.quantity,
      })}");

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return Book(
          id: data['bookId'],
          title: book.title,
          author: book.author,
          description: book.description,
          price: book.price,
          imageUrl: book.imageUrl,
          rating: book.rating,
          quantity: book.quantity,
          roles: book.roles,
        );
      } else {
        throw Exception('Failed to create book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating book: $e');
    }
  }

  // Update an existing book
  Future<Book> updateBook(Book book) async {
    try {
      if (book.id == null) {
        throw Exception('Book ID cannot be null for update');
      }

      // Debug the book data
      print('Book object being updated:');
      print('ID: ${book.id}');
      print('Title: ${book.title}');
      print('Author: ${book.author}');
      
      // Convert Book object to match backend's expected field names
      final Map<String, dynamic> requestData = {
        'title': book.title,
        'author': book.author,
        'description': book.description,
        'price': book.price,
        'ma_nha_xuat_ban': book.publisher, // USING DATABASE COLUMN NAME
        'url_anh': book.imageUrl, // USING DATABASE COLUMN NAME
        'category': book.category,
        'rating': book.rating,
        'so_luong': book.quantity,
      };

      // Ensure ID is correctly formatted in URL
      final url = '$baseUrl/${book.id}';
      print('Update URL: $url');
      print('Update payload: $requestData');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        return book; // Return the updated book
      } else {
        throw Exception('Failed to update book: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error updating book: $e');
      throw Exception('Error updating book: $e');
    }
  }

  // Delete a book
  Future<bool> deleteBook(int bookId) async {
    try {
      // Debug log to see what's being sent to the server
      print('Deleting book with ID: $bookId');
      
      final response = await http.delete(Uri.parse('$baseUrl/$bookId'));
      
      // Debug log the response
      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Successful deletion
      } else {
        throw Exception('Failed to delete book: ${response.statusCode}, message: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteBook: $e');
      throw Exception('Error deleting book: $e');
    }
  }

  // Rate a book
  Future<void> rateBook(int bookId, double rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$bookId/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rating': rating}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rate book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rating book: $e');
    }
  }
}
