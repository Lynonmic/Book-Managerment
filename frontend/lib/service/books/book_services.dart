import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/book_model.dart';

class BookService {
  // Replace with your actual API URL
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Fetch all books
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));

      if (response.statusCode == 200) {
        // Check if the response is a map with a data field that contains the list
        final dynamic parsedJson = json.decode(response.body);

        if (parsedJson is Map<String, dynamic> &&
            parsedJson.containsKey('data')) {
          // If it's a map with a 'data' field containing the list
          final List<dynamic> data = parsedJson['data'];
          return data.map((json) => Book.fromJson(json)).toList();
        } else if (parsedJson is List) {
          // If it's directly a list
          return parsedJson.map((json) => Book.fromJson(json)).toList();
        } else {
          // Unexpected format
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  // Fetch a specific book by ID
  Future<Book> fetchBookById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/$id'));

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

  // Rate a book
  Future<Book> rateBook(int id, double rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books/$id/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rating': rating}),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to rate book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rating book: $e');
    }
  }

  // Update a book
  Future<Book> updateBook(Book book) async {
    if (book.id == null) {
      throw Exception('Book ID cannot be null for update operation');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/books/${book.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception(
          'Failed to update book: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating book: $e');
    }
  }

  // Delete a book
  Future<bool> deleteBook(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete book: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }
}
