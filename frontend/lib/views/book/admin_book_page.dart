import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/widget/action_button.dart';
import 'package:frontend/widget/rating_star.dart';
import 'package:frontend/widget/category_pills.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:frontend/widget/backbutton_and_title.dart';
import 'package:frontend/widget/primary_button.dart';
import 'package:frontend/model/PublisherModels.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;
  final Function(Book) onSave;

  const BookFormScreen({Key? key, this.book, required this.onSave})
    : super(key: key);

  @override
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _publisherController;

  String? _imageUrl;
  File? _imageFile;
  double _rating = 0.0;

  // Add categories list and active category
  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Technology',
    'Romance',
    'Mystery',
    'Thriller',
    'Self-Help',
  ];

  String _activeCategory = 'All'; // Default category

  // Add publisher-related state
  bool _isLoadingPublishers = false;
  String? _selectedPublisherId;
  String? _selectedPublisherName;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the book data if editing
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _descriptionController = TextEditingController(
      text: widget.book?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.book?.price?.toString() ?? '',
    );
    _publisherController = TextEditingController(
      text: widget.book?.publisher ?? '',
    );

    _imageUrl = widget.book?.imageUrl;
    _rating = widget.book?.rating?.toDouble() ?? 0.0;

    // Set the active category if book has one
    if (widget.book?.category != null && widget.book!.category!.isNotEmpty) {
      _activeCategory = widget.book!.category!;
    }

    // Set the selected publisher ID from the book's author field
    _selectedPublisherId = widget.book?.author;

    // Fetch publishers for the dropdown
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _imageUrl = null; // Clear the URL when a file is picked
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _selectImageFromAssets() {
    // List of predefined images from assets (just filenames)
    List<String> assetImages = [
      'baythoiquenthanhdat.jpg',
      'C++_thap_cao.jpg',
      'conan.jpg',
      'dachantam86.jpg',
      'dayconlamgiau.jpg',
      'doraemon.png',
      'hanhtrinphuongdong.jpg',
      'harryposter.jpg',
      'lichsuVN.jpg',
      'logo.png',
      'nhagiakim.jpg',
      'oxford.jpg',
      'sapiens-luoc-su-ve-loai-nguoi.png',
      'sucmanhngontu.jpg',
      'thientaitrai_kedienphai.jpg',
      'vutru trong vo hat.jpg',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select from Assets'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: assetImages.length,
              itemBuilder: (context, index) {
                final assetPath = assetImages[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageUrl = assetPath; // Store the filename
                      _imageFile = null; // Clear any picked file
                    });
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/$assetPath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Error loading image'));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.collections),
                title: Text('Assets'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromAssets();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id,
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        publisher: _selectedPublisherName,
        imageUrl: _imageUrl,
        rating: _rating,
        category: _activeCategory == 'All' ? '' : _activeCategory,
        roles: 1, // Admin role
      );

      print("Saving book: ${book.toJson()}"); // Log the book data

      widget.onSave(book);
      Navigator.pop(context);
    } else {
      print("Form is invalid.");
    }
  }

  void _deleteBook() {
    if (widget.book?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete a book without an ID')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this book?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  final provider = Provider.of<BookProvider>(
                    context,
                    listen: false,
                  );
                  final success = await provider.deleteBook(widget.book!.id!);

                  if (success) {
                    Navigator.pop(context); // Go back to book list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Book deleted successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to delete book: ${provider.error}',
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add New Book' : 'Edit Book'),
        actions:
            widget.book != null
                ? [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteBook,
                  ),
                ]
                : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Image Picker
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: Container(
                    width: 200,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _buildImageWidget(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Book Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
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
              SizedBox(height: 16),

              // Category Pills
              Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              CategoryPills(
                categories: _categories,
                activeCategory: _activeCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _activeCategory = category;
                  });
                },
              ),
              SizedBox(height: 16),

              // Author
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
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
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Rating
              Text(
                'Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              InteractiveStarRating(
                initialRating: _rating,
                maxRating: 5,
                color: Colors.amber,
                size: 28,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 24),

              // Save Button
              PrimaryButton(label: 'Save Book', onPressed: _saveBook),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      // Show picked image file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    } else if (_imageUrl != null) {
      // If the image URL is a network URL
      if (_imageUrl!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text('Error loading image'));
            },
          ),
        );
      } else {
        // Correct asset path
        return Image.asset(
          'assets/images/$_imageUrl', // Correct path
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Text('Error loading image'));
          },
        );
      }
    } else {
      // Show placeholder with camera icon
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text('Tap to add image', style: TextStyle(color: Colors.grey[600])),
        ],
      );
    }
  }
}
