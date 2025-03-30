import 'package:flutter/material.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/widget/dropdown_field.dart';
import 'package:frontend/widget/image_placeholder.dart';
import 'package:frontend/widget/number_input_field.dart';
import 'package:frontend/widget/text_input_field.dart';
import 'package:provider/provider.dart';

class BookFormScreen extends StatefulWidget {
  final Book book;
  final Function(Book) onSave;

  const BookFormScreen({Key? key, required this.book, required this.onSave})
    : super(key: key);

  @override
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with book data
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _descriptionController = TextEditingController(
      text: widget.book.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.book.price != null ? widget.book.price.toString() : '',
    );
    _imageUrlController = TextEditingController(
      text: widget.book.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated book object
        final updatedBook = widget.book.copyWith(
          title: _titleController.text,
          author: _authorController.text,
          description: _descriptionController.text,
          price:
              _priceController.text.isNotEmpty
                  ? double.parse(_priceController.text)
                  : null,
          imageUrl:
              _imageUrlController.text.isNotEmpty
                  ? _imageUrlController.text
                  : null,
        );

        // Call the onSave callback
        widget.onSave(updatedBook);

        // Update the book in the provider
        // No need to cast, it's already a Book
        await Provider.of<BookProvider>(
          context,
          listen: false, // Add listen: false to avoid rebuild during operation
        ).updateBook(updatedBook);

        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.id != null ? 'Edit Book' : 'Add Book'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveBook),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      if (_imageUrlController.text.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),

                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
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
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an author';
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
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),

                      // Price field
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Please enter a valid price';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image URL field
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Update UI when URL changes
                          if (value.isNotEmpty) {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Book ID (read-only)
                      if (widget.book.id != null) ...[
                        Text(
                          'Book ID: ${widget.book.id}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Rating information (read-only)
                      if (widget.book.rating != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Current Rating: ${widget.book.rating!.toStringAsFixed(1)} (${widget.book.ratingCount ?? 0} reviews)',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Save button
                      ElevatedButton(
                        onPressed: _saveBook,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Save Book'),
                      ),

                      if (widget.book.id != null) ...[
                        const SizedBox(height: 16),
                        // Delete button
                        ElevatedButton(
                          onPressed: () {
                            // Show delete confirmation dialog
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Delete Book'),
                                    content: const Text(
                                      'Are you sure you want to delete this book?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(ctx).pop();
                                          try {
                                            // Use null check instead of casting
                                            if (widget.book.id != null) {
                                              await Provider.of<BookProvider>(
                                                context,
                                                listen: false,
                                              ).deleteBook(widget.book.id!);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Book deleted successfully',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              Navigator.of(
                                                context,
                                              ).pop(); // Return to book list
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error deleting book: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Delete Book'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
