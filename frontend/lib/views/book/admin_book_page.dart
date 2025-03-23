// lib/screens/book_form_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/widget/dropdown_field.dart';
import 'package:frontend/widget/image_placeholder.dart';
import 'package:frontend/widget/number_input_field.dart';
import 'package:frontend/widget/text_input_field.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;
  final Function(Book) onSave;

  const BookFormScreen({super.key, this.book, required this.onSave});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  late String _title;
  late String _author;
  String? _description;
  String? _imageUrl;
  double? _price;
  String? _publisher;
  int? _pageCount;
  String? _isbn;
  double? _rating;
  int? _ratingCount;

  final List<String> _publishers = [
    'Penguin Random House',
    'HarperCollins',
    'Simon & Schuster',
    'Macmillan Publishers',
    'Hachette Book Group',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.book?.title ?? '';
    _author = widget.book?.author ?? '';
    _description = widget.book?.description;
    _imageUrl = widget.book?.imageUrl;
    _price = widget.book?.price;
    _publisher = widget.book?.publisher;
    _pageCount = widget.book?.pageCount;
    _isbn = widget.book?.isbn;
    _rating = widget.book?.rating;
    _ratingCount = widget.book?.ratingCount;
  }

  void _saveBook() {
    final book = Book(
      id: widget.book?.id ?? '',
      title: _title,
      author: _author,
      description: _description,
      imageUrl: _imageUrl,
      price: _price,
      publisher: _publisher,
      pageCount: _pageCount,
      isbn: _isbn,
      createdAt: widget.book?.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      rating: _rating,
      ratingCount: _ratingCount,
    );
    widget.onSave(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookImagePicker(
                imageUrl: _imageUrl,
                onImageSelected: (url) {
                  setState(() {
                    _imageUrl = url;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextInputField(
                label: 'Title',
                value: _title,
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                isRequired: true,
              ),

              TextInputField(
                label: 'Author',
                value: _author,
                onChanged: (value) {
                  setState(() {
                    _author = value;
                  });
                },
                isRequired: true,
              ),

              DropdownField(
                label: 'Publisher',
                value: _publisher ?? '',
                options: _publishers,
                onChanged: (value) {
                  setState(() {
                    _publisher = value;
                  });
                },
              ),

              TextInputField(
                label: 'Description',
                value: _description ?? '',
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                maxLines: 5,
                isRequired: false,
              ),

              NumberInputField(
                label: 'Price',
                value: _price,
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
                isDecimal: true,
                prefix: '\$',
              ),

              NumberInputField(
                label: 'Page Count',
                value: _pageCount?.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _pageCount = value?.toInt();
                  });
                },
              ),

              TextInputField(
                label: 'ISBN',
                value: _isbn ?? '',
                onChanged: (value) {
                  setState(() {
                    _isbn = value;
                  });
                },
                isRequired: false,
              ),

              NumberInputField(
                label: 'Rating',
                value: _rating,
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
                isDecimal: true,
                min: 0,
                max: 5,
                suffix: '/ 5',
              ),

              NumberInputField(
                label: 'Rating Count',
                value: _ratingCount?.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _ratingCount = value?.toInt();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextButton(
                onPressed: () {
                  if (_title.isEmpty || _author.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title and Author are required'),
                      ),
                    );
                    return;
                  }
                  _saveBook();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final double? price;
  final String? publisher;
  final int? pageCount;
  final String? isbn;
  final String? createdAt;
  final String? updatedAt;
  final double? rating;
  final int? ratingCount;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    this.price,
    this.publisher,
    this.pageCount,
    this.isbn,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.ratingCount,
  });
}
