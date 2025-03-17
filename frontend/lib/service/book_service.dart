import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/book_model.dart';

class BookService {
  final String baseUrl = 'http://10.0.2.2:9090/api';

  // Get all books
  Future<List<BookModel>> getAllBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/home'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => BookModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get a book by ID
  Future<BookModel> getBookById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode == 200) {
      return BookModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load book details');
    }
  }

  // Rate a book
  Future<BookModel> rateBook(int id, double rating) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$id/rate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'rating': rating}),
    );

    if (response.statusCode == 200) {
      return BookModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to rate book');
    }
  }

  // Search books
  Future<List<BookModel>> searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/search?query=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => BookModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  // Get home page books
  Future<Map<String, List<BookModel>>> getHomePageBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books/home'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      Map<String, List<BookModel>> result = {};
      jsonResponse.forEach((key, value) {
        if (value is List) {
          result[key] =
              (value)
                  .map((bookData) => BookModel.fromJson(bookData))
                  .toList();
        }
      });

      return result;
    } else {
      throw Exception('Failed to load home page books');
    }
  }
}
