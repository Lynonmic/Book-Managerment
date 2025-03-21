import 'package:flutter/material.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/book_service.dart';
import 'package:frontend/widget/book_item.dart';

class BookPageUser extends StatefulWidget {
  const BookPageUser({Key? key}) : super(key: key);

  @override
  State<BookPageUser> createState() => _BookPageUserState();
}

class _BookPageUserState extends State<BookPageUser> {
  final BookService _bookService = BookService();
  List<BookModel> _books = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBooks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(child: Text('No books available'));
    }

    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return BookItem(
            title: book.title,
            description: book.description ?? 'No description available',
            rating: book.rating?.round() ?? 0,
            onTap: () {
              // Show book details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(book.title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (book.imageUrl != null)
                        Image.network(
                          book.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, _) => Container(
                            height: 150,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text('Author: ${book.author ?? 'Unknown'}'),
                      const SizedBox(height: 8),
                      Text('Price: \$${book.price.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Quantity: ${book.quantity}'),
                      const SizedBox(height: 8),
                      Text(
                        'Rating: ${book.rating?.toStringAsFixed(1) ?? 'Not rated'} (${book.ratingCount ?? 0} reviews)',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
