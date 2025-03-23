import 'package:flutter/material.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';

// Define the StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Updated HomeScreen State
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentItemType = 'books';

  @override
  void initState() {
    super.initState();
    // Fetch books when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
  }

  // Build book list
  Widget _buildBookList() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (bookProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(bookProvider.error, style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => bookProvider.fetchBooks(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (bookProvider.books.isEmpty) {
          return Center(child: Text('No books found'));
        }

        return RefreshIndicator(
          onRefresh: () => bookProvider.refreshBooks(),
          child: ListView.builder(
            itemCount: bookProvider.books.length,
            itemBuilder: (context, index) {
              final book = bookProvider.books[index];
              return BookItem(
                title: book.title,
                description: book.description ?? 'No description available',
                rating:
                    book.rating?.round() ??
                    0, // This is correct, but ensure BookItem accepts this as int
                onTap: () {
                  // Show book details with rating option
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
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
                                  errorBuilder:
                                      (ctx, error, _) => Container(
                                        height: 150,
                                        color: Colors.grey.shade300,
                                        child: Icon(Icons.image, size: 50),
                                      ),
                                ),
                              SizedBox(height: 16),
                              Text('Author: ${book.author}'),
                              SizedBox(height: 8),
                              Text(
                                'Rating: ${book.rating?.toStringAsFixed(1) ?? 'Not rated'} (${book.ratingCount ?? 0} reviews)',
                              ),
                              SizedBox(height: 16),
                              Text('Rate this book:'),
                              SizedBox(height: 8),
                              InteractiveStarRating(
                                onRatingChanged: (rating) async {
                                  Navigator.pop(context);
                                  try {
                                    if (book.id != null) {
                                      // Ensure conversion to double
                                      await Provider.of<BookProvider>(
                                        context,
                                        listen: false,
                                      ).rateBook(book.id!, rating.toDouble());

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Rating submitted: $rating stars',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to rate book: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Handle rating changes by ensuring double conversion
  void _handleRatingChanged(int bookId, int rating) async {
    try {
      // Convert the integer rating to a double explicitly
      await Provider.of<BookProvider>(
        context,
        listen: false,
      ).rateBook(bookId, rating.toDouble());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted: $rating stars')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  // Rate a book - now uses the provider
  Future<void> _rateBook(int bookId, double rating) async {
    try {
      await Provider.of<BookProvider>(
        context,
        listen: false,
      ).rateBook(bookId, rating);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted: $rating stars')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  // Handle option menu selection with updated book provider
  void _handleOptionSelected(String value) {
    setState(() {
      _currentItemType = value;
      _currentIndex = 0;

      if (value == 'ratings') {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        if (bookProvider.books.isNotEmpty) {
          final book = bookProvider.books.first;
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Rate Book: ${book.title}'),
                  content: InteractiveStarRating(
                    onRatingChanged: (rating) {
                      Navigator.pop(context);
                      if (book.id != null) {
                        _rateBook(book.id!, rating.toDouble());
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
          );
          _currentItemType = 'books';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Manager'),
        actions: [
          OptionMenu(onOptionSelected: _handleOptionSelected),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BookProvider>(context, listen: false).refreshBooks();
            },
          ),
        ],
      ),
      body:
          _currentItemType == 'books'
              ? _buildBookList()
              : Center(child: Text('Coming soon: $_currentItemType')),
      bottomNavigationBar: BottomMenu(
        currentIndex: _currentIndex,
        initialIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
