import 'package:flutter/material.dart';
import 'package:frontend/controllers/book_functions.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/book_service.dart';
import 'package:frontend/views/book/user_book_page.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
      routes: {
        '/user_book_page': (context) => Scaffold(
              appBar: AppBar(title: Text('User Book Page')),
              body: const BookPageUser(),
            ),
      },
    );
  }
}

// Example screen that uses the BottomMenu
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Track currently displayed item type
  String _currentItemType = 'books'; // Default to books

  // Service for API calls
  final BookService _bookService = BookService();

  // State variables to hold API data
  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  // Fetch books from API
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load books: $e';
        _isLoading = false;
      });
    }
  }

  // Rate a book
  Future<void> _rateBook(int bookId, double rating) async {
    try {
      await _bookService.rateBook(bookId, rating);
      // Refresh the book list after rating
      _fetchBooks();
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context,
            message: 'Failed to rate book: $e');
      }
    }
  }

  final List<Widget> _pages = [
    const Center(child: Text('Home Page')),
    const Center(child: Text('Cart Page')),
    const Center(child: Text('Cart Page')),
    const Center(child: Text('Search Page')),
    const Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which content to show based on navigation index
    Widget mainContent;

    if (_currentIndex == 0) {
      // Show items based on selection when on the home tab
      mainContent = _buildItemList();
    } else {
      // Use the existing pages for other tabs
      mainContent = _pages[_currentIndex];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          OptionMenu(
            onOptionSelected: (value) {
              _handleOptionSelected(context, value);
            },
            tooltip: 'More options',
          ),
        ],
      ),
      body: mainContent,
      bottomNavigationBar: BottomMenu(
        initialIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Build the appropriate item list based on current selection
  Widget _buildItemList() {
    switch (_currentItemType) {
      case 'books':
        return _buildBookList();
      case 'users':
        return _buildUserList();
      case 'authors':
        return _buildAuthorList();
      default:
        return _buildBookList();
    }
  }

  // Build book list
  Widget _buildBookList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBooks,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(child: Text('No books found'));
    }

    return RefreshIndicator(
      onRefresh: _fetchBooks,
      child: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return BookItem(
            title: book.title,
            description: book.description ?? 'No description available',
            rating: book.rating?.round() ?? 0,
            onTap: () {
              // Show book details with rating option
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
                      Text(
                        'Rating: ${book.rating?.toStringAsFixed(1) ?? 'Not rated'} (${book.ratingCount ?? 0} reviews)',
                      ),
                      const SizedBox(height: 16),
                      const Text('Rate this book:'),
                      const SizedBox(height: 8),
                      InteractiveStarRating(
                        onRatingChanged: (rating) {
                          Navigator.pop(context);
                          if (book.id != null) {
                            _rateBook(book.id!, rating.toDouble());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cannot rate this book: ID is missing',
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

  // Build user list - placeholder since we're focusing on books
  Widget _buildUserList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('User data would be fetched from API'),
          ElevatedButton(
            onPressed: () {
              // Placeholder for user API functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User API integration not implemented yet'),
                ),
              );
            },
            child: Text('Load Users'),
          ),
        ],
      ),
    );
  }

  // Build author list - placeholder since we're focusing on books
  Widget _buildAuthorList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Author data would be fetched from API'),
          ElevatedButton(
            onPressed: () {
              // Placeholder for author API functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Author API integration not implemented yet'),
                ),
              );
            },
            child: Text('Load Authors'),
          ),
        ],
      ),
    );
  }

  // Update the title based on current index and item type
  String _getTitle() {
    if (_currentIndex == 0) {
      switch (_currentItemType) {
        case 'books':
          return 'Book List';
        case 'users':
          return 'User List';
        case 'publisher':
          return 'Publisher List';
        default:
          return 'Book List';
      }
    } else {
      // Existing titles for other tabs
      switch (_currentIndex) {
        case 1:
          return 'Cart Page';
        case 2:
          return 'Search Page';
        case 3:
          return 'Profile Page';
        default:
          return 'Home';
      }
    }
  }

  // Handle option menu selection
  void _handleOptionSelected(BuildContext context, String value) {
    // Update the current item type
    setState(() {
      _currentItemType = value;
      // Make sure we're on the first tab to see the items
      _currentIndex = 0;

      // If selecting ratings, show a dialog to rate a book
      if (value == 'ratings' && _books.isNotEmpty) {
        final book =
            _books.first; // Just an example, could show a list to select from
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Rate Book: ${book.title}'),
            content: InteractiveStarRating(
              onRatingChanged: (rating) {
                Navigator.pop(context);
                if (book.id != null) {
                  _rateBook(book.id!, rating.toDouble());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot rate this book: ID is missing'),
                    ),
                  );
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        _currentItemType = 'books'; // Reset to books view after rating
      }
    });
  }
}
