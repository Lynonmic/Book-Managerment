import 'package:flutter/material.dart';
import 'package:frontend/controllers/book_functions.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/book_service.dart';
import 'package:frontend/widget/rating_star.dart';

class BookWatchPage extends StatefulWidget {
  final int bookId;
  final BookModel? initialData; // Optional initial data to show while loading

  const BookWatchPage({
    super.key,
    required this.bookId,
    this.initialData,
  });

  @override
  State<BookWatchPage> createState() => _BookWatchPageState();
}

class _BookWatchPageState extends State<BookWatchPage> {
  final _bookService = BookService();

  BookModel? _book;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _book = widget.initialData; // Use initial data if available
    _fetchBookDetails();
  }

  // Fetch book details from API
  Future<void> _fetchBookDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final book = await _bookService.getBookById(widget.bookId);
      if (mounted) {
        setState(() {
          _book = book;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load book details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show initial data while loading or error with initial data
    final isShowingInitialData = _isLoading && widget.initialData != null;
    final bookToDisplay = _book ?? widget.initialData;

    return Scaffold(
      appBar: AppBar(
        title: Text(bookToDisplay?.title ?? 'Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchBookDetails,
          ),
          if (bookToDisplay != null)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                NotificationService.showInfo(
                  context,
                  message: 'Added to cart: ${bookToDisplay.title}',
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              NotificationService.showInfo(
                context,
                message: 'Share functionality not implemented',
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, bookToDisplay, isShowingInitialData),
    );
  }

  Widget _buildBody(
      BuildContext context, BookModel? book, bool isShowingInitialData) {
    if (_isLoading && widget.initialData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && book == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBookDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (book == null) {
      return const Center(child: Text('Book not found'));
    }

    return RefreshIndicator(
      onRefresh: _fetchBookDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading indicator for refreshing with initial data
            if (isShowingInitialData) const LinearProgressIndicator(),

            // Book cover image
            if (book.imageUrl != null)
              SizedBox(
                width: double.infinity,
                height: 250,
                child: Image.network(
                  book.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, _) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),

            // Book details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.author != null) ...[
                    Text(
                      'By ${book.author}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'In Stock: ${book.quantity}',
                        style: TextStyle(
                          color: book.quantity > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  if (book.rating != null) ...[
                    Row(
                      children: [
                        RatingStar(rating: book.rating!.round()),
                        const SizedBox(width: 8),
                        Text(
                          '${book.rating!.toStringAsFixed(1)} (${book.ratingCount ?? 0} reviews)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Additional details
                  if (book.categoryId != null || book.publisherId != null) ...[
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (book.categoryId != null)
                      Text('Category ID: ${book.categoryId}'),
                    if (book.publisherId != null)
                      Text('Publisher ID: ${book.publisherId}'),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        NotificationService.showSuccess(
                          context,
                          message: '${book.title} added to cart!',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Write a Review'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        _showReviewDialog(context, book);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review ${book.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate this book:'),
            const SizedBox(height: 8),
            InteractiveStarRating(
              onRatingChanged: (rating) async {
                Navigator.pop(context);
                try {
                  await _bookService.rateBook(book.id!, rating.toDouble());
                  await _fetchBookDetails(); // Refresh to get updated rating
                  if (mounted) {
                    NotificationService.showSuccess(
                      context,
                      message: 'Thank you for your rating!',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    NotificationService.showError(
                      context,
                      message: 'Failed to submit rating: $e',
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
