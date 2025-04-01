import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/book_model.dart';

class BookService {
  final String baseUrl =
      'http://10.0.2.2:3000/api/books'; // Update with your API URL

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
      // Prepare the request data to match the backend insert query structure
      final requestData = {
        'title': book.title, // ten_sach
        'author': book.author ?? '', // tac_gia - cannot be null
        'description': book.description ?? '', // mo_ta - cannot be null
        'imageUrl': book.imageUrl, // url_anh
        'price': book.price, // gia
        'publisherId': book.publisherId, // ma_nha_xuat_ban
        'quantity': book.quantity ?? 0, // so_luong - cannot be null
        'category': book.category, // ma_danh_muc
      };

      // Ensure quantity is never null
      if (requestData['quantity'] == null) {
        requestData['quantity'] = 0; // Set default value to 0
      }

      // Log the request for debugging
      print('Creating book with data that matches backend SQL structure:');
      print('- title (ten_sach): ${book.title}');
      print('- author (tac_gia): ${book.author ?? ""}');
      print('- description (mo_ta): ${book.description ?? ""}');
      print('- imageUrl (url_anh): ${book.imageUrl}');
      print('- price (gia): ${book.price}');
      print('- publisherId (ma_nha_xuat_ban): ${book.publisherId}');
      print(
        '- quantity (so_luong): ${book.quantity ?? 0}',
      ); // Show default value if null
      print('- category (ma_danh_muc): ${book.category}');

      // Send the POST request
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      // Debug log the response
      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception(
          'Failed to create book: ${response.statusCode}, message: ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating book: $e');
      throw Exception('Error creating book: $e');
    }
  }

  // Update an existing book
  Future<Book> updateBook(Book book) async {
    try {
      if (book.id == null) {
        throw Exception('Book ID cannot be null for update operation');
      }

      // Prepare the request data with the same structure as create
      final requestData = {
        'title': book.title, // ten_sach
        'author': book.author ?? '', // tac_gia - cannot be null
        'description': book.description ?? '', // mo_ta - cannot be null
        'imageUrl': book.imageUrl, // url_anh
        'price': book.price, // gia
        'publisherId': book.publisherId, // ma_nha_xuat_ban
        'quantity': book.quantity ?? 0, // so_luong - cannot be null
        'category': book.category, // ma_danh_muc
      };

      // Ensure quantity is never null
      if (requestData['quantity'] == null) {
        requestData['quantity'] = 0; // Set default value to 0
      }

      print('Updating book ID ${book.id} with data: $requestData');

      // Send the PUT request
      final response = await http.put(
        Uri.parse('$baseUrl/${book.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to update book: ${response.statusCode}');
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
        throw Exception(
          'Failed to delete book: ${response.statusCode}, message: ${response.body}',
        );
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
