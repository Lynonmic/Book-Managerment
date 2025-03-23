import 'package:flutter/material.dart';
import 'package:frontend/controllers/book_functions.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/book_service.dart';

class AdminEditPage extends StatefulWidget {
  final int? bookId; // Pass bookId for editing, null for adding new book
  const AdminEditPage({super.key, this.bookId});

  @override
  State<AdminEditPage> createState() => _AdminEditPageState();
}

class _AdminEditPageState extends State<AdminEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _categoryIdController;
  late TextEditingController _publisherIdController;

  bool _isLoading = false;
  bool _isInitialLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  BookModel? _originalBook;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.bookId != null;

    // Initialize controllers with empty values
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _priceController = TextEditingController(text: '0.0');
    _quantityController = TextEditingController(text: '0');
    _categoryIdController = TextEditingController();
    _publisherIdController = TextEditingController();

    // If editing, fetch book details from API
    if (_isEditing) {
      _fetchBookDetails();
    }
  }

  // Fetch book details from API
  Future<void> _fetchBookDetails() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.bookId != null) {
        final book = await _bookService.getBookById(widget.bookId!);
        _originalBook = book;

        // Populate form controllers with book data
        _titleController.text = book.title;
        _authorController.text = book.author ?? '';
        _descriptionController.text = book.description ?? '';
        _imageUrlController.text = book.imageUrl ?? '';
        _priceController.text = book.price.toString();
        _quantityController.text = book.quantity.toString();
        _categoryIdController.text = book.categoryId?.toString() ?? '';
        _publisherIdController.text = book.publisherId?.toString() ?? '';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book details: $e';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryIdController.dispose();
    _publisherIdController.dispose();
    super.dispose();
  }

  // Save the book (create new or update existing)
  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Create book object from form data
        final book = BookModel(
          id: widget.bookId, // null for new books, existing id for updates
          title: _titleController.text,
          author:
              _authorController.text.isEmpty ? null : _authorController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          imageUrl: _imageUrlController.text.isEmpty
              ? null
              : _imageUrlController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          categoryId: _categoryIdController.text.isEmpty
              ? null
              : int.tryParse(_categoryIdController.text),
          publisherId: _publisherIdController.text.isEmpty
              ? null
              : int.tryParse(_publisherIdController.text),
          rating: _originalBook?.rating, // Preserve existing rating if any
          ratingCount: _originalBook?.ratingCount, // Preserve existing count
        );

        // if (_isEditing && widget.bookId != null) {
        //   // Update existing book
        //   await _bookService.updateBook(widget.bookId!, book);
        //   if (mounted) {
        //     NotificationService.showSuccess(context,
        //         message: 'Book updated successfully');
        //   }
        // } else {
        //   // Create new book
        //   await _bookService.createBook(book);
        //   if (mounted) {
        //     NotificationService.showSuccess(context,
        //         message: 'Book added successfully');
        //   }
        // }

        // Return to previous screen
        if (mounted) {
          Navigator.pop(context, true); // true indicates success
        }
      } catch (e) {
        // Show error
        setState(() {
          _errorMessage = 'Failed to save book: $e';
        });
        if (mounted) {
          NotificationService.showError(context,
              message: 'Failed to save book: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Book' : 'Add New Book'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh book data',
              onPressed: _fetchBookDetails,
            ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _isEditing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchBookDetails,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            hintText: 'Enter book title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Author field
                        TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Author',
                            hintText: 'Enter author name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price field
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price *',
                            hintText: 'Enter book price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quantity field
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                            hintText: 'Enter book quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a quantity';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity < 0) {
                              return 'Please enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter book description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),

                        // Image URL field
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                            hintText: 'Enter URL for book cover image',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              bool validURL =
                                  Uri.tryParse(value)?.hasAbsolutePath ?? false;
                              if (!validURL) {
                                return 'Please enter a valid URL';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category ID field
                        TextFormField(
                          controller: _categoryIdController,
                          decoration: const InputDecoration(
                            labelText: 'Category ID',
                            hintText: 'Enter category ID',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final categoryId = int.tryParse(value);
                              if (categoryId == null || categoryId <= 0) {
                                return 'Please enter a valid category ID';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Publisher ID field
                        TextFormField(
                          controller: _publisherIdController,
                          decoration: const InputDecoration(
                            labelText: 'Publisher ID',
                            hintText: 'Enter publisher ID',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final publisherId = int.tryParse(value);
                              if (publisherId == null || publisherId <= 0) {
                                return 'Please enter a valid publisher ID';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Preview of image if URL is provided
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text('Invalid image URL'),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Error message if saving failed
                        if (_errorMessage != null && !_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveBook,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(_isEditing
                                        ? 'Update Book'
                                        : 'Add Book'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
