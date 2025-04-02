import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/controllers/users_controller.dart';
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
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/categories/category_provider.dart';

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
  late TextEditingController _quantityController;

  String? _imageUrl;
  File? _imageFile;
  double _rating = 0.0;

  // Replace hardcoded categories list with a dynamic list from the API
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _errorCategories;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Add publisher-related state
  bool _isLoadingPublishers = false;
  String? _selectedPublisherId;
  String? _selectedPublisherName;
  List<Publishermodels> _publishers = [];
  String? _errorPublisher;
  PublisherController _controller =
      PublisherController(); // Changed variable name to match HomeScreen

  @override
  void initState() {
    super.initState();
    _controller =
        PublisherController(); // Initialize PublisherController with the renamed variable
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
    _quantityController = TextEditingController(
      text: widget.book?.quantity?.toString() ?? '0',
    );

    _imageUrl = widget.book?.imageUrl;

    // Set the selected publisher ID and name if editing a book
    if (widget.book?.publisherId != null) {
      _selectedPublisherId = widget.book!.publisherId;
    }

    // Use post-frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
      _fetchPublishers();
    });
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _errorCategories = null;
    });

    try {
      // Get the provider outside of setState
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final categories = await categoryProvider.fetchCategories();

      // Use a post-frame callback to avoid setState during build
      if (mounted) {
        setState(() {
          _categories = categoryProvider.categories;
          _isLoadingCategories = false;

          // If editing a book, set the selected category
          if (widget.book?.category != null &&
              widget.book!.category!.isNotEmpty) {
            _selectedCategoryId = widget.book!.category;
            // Find the category name based on the ID
            final category = _categories.firstWhere(
              (cat) => cat.id.toString() == _selectedCategoryId,
              orElse: () => CategoryModel(id: 0, name: 'Unknown'),
            );
            _selectedCategoryName = category.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCategories = 'Failed to load categories: $e';
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchPublishers() async {
    setState(() {
      _isLoadingPublishers = true;
      _errorPublisher = null;
    });

    try {
      final publishers = await _controller.fetchPublishers();

      if (mounted) {
        setState(() {
          _publishers = publishers;
          _isLoadingPublishers = false;

          // If we're editing a book and have a publisher ID, find and set the name
          if (_selectedPublisherId != null) {
            final publisher = _publishers.firstWhere(
              (p) => p.maNhaXuatBan.toString() == _selectedPublisherId,
              orElse: () => Publishermodels(),
            );
            _selectedPublisherName = publisher.tenNhaXuatBan;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorPublisher = 'Failed to load publishers: $e';
          _isLoadingPublishers = false;
        });
      }
    }
  }

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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _publisherController.dispose();
    _quantityController.dispose();
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
      // Ensure the publisher ID is correctly formatted before saving
      final publisherId = _selectedPublisherId;

      final book = Book(
        id: widget.book?.id, // Keep the id for updates, null for new books
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        publisherId: publisherId,
        imageUrl: _imageUrl,
        category: _selectedCategoryId,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        roles: 1,
      );

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

    // Get the provider reference BEFORE showing the dialog
    final provider = Provider.of<BookProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            // Note: using dialogContext here
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this book?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close dialog

                  // Use the provider reference we captured earlier
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

              // Replace Category Dropdown with one that uses real data
              Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _isLoadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Category',
                    ),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id.toString(),
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategoryId = newValue;
                          final category = _categories.firstWhere(
                            (c) => c.id.toString() == newValue,
                            orElse: () => CategoryModel(id: 0, name: 'Unknown'),
                          );
                          _selectedCategoryName = category.name;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
              SizedBox(height: 16),

              // Publisher Dropdown
              Text(
                'Publisher',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _isLoadingPublishers
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                    value: _selectedPublisherId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Publisher',
                    ),
                    items:
                        _publishers.map((publisher) {
                          return DropdownMenuItem<String>(
                            value: publisher.maNhaXuatBan.toString(),
                            child: Text(publisher.tenNhaXuatBan ?? 'Unknown'),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPublisherId = newValue;
                          // Log the selected publisher ID for debugging
                          print("Selected publisher ID: $_selectedPublisherId");
                          final publisher = _publishers.firstWhere(
                            (p) => p.maNhaXuatBan.toString() == newValue,
                            orElse: () => Publishermodels(),
                          );
                          _selectedPublisherName = publisher.tenNhaXuatBan;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a publisher';
                      }
                      return null;
                    },
                  ),
              SizedBox(height: 16),

              // Author input (now optional since we use publisher ID)
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author Name (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter author name if different from publisher',
                ),
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

              // Quantity input
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

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
