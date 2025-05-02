import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/book/book_bloc.dart';
import 'package:frontend/blocs/book/book_event.dart';
import 'package:frontend/blocs/book/book_state.dart';
import 'package:frontend/blocs/category/category_bloc.dart';
import 'package:frontend/blocs/category/category_event.dart';
import 'package:frontend/blocs/category/category_state.dart';
import 'package:frontend/blocs/publisher/publisher_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_event.dart';
import 'package:frontend/blocs/publisher/publisher_state.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/screens/widget/action_button.dart';
import 'package:frontend/screens/widget/rating_star.dart';
import 'package:frontend/screens/widget/category_pills.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:frontend/screens/widget/backbutton_and_title.dart';
import 'package:frontend/screens/widget/primary_button.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/category_model.dart';

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
  bool _isDeleting = false;

  // State for categories and publishers
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Publisher-related state
  String? _selectedPublisherId;
  String? _selectedPublisherName;
  List<Publishermodels> _publishers = [];

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
    _quantityController = TextEditingController(
      text: widget.book?.quantity?.toString() ?? '0',
    );

    _imageUrl = widget.book?.imageUrl;

    // Set the selected category if editing
    if (widget.book?.category != null) {
      _selectedCategoryId = widget.book!.category.toString();
    }

    // Set the selected publisher ID and name if editing a book
    if (widget.book?.publisherId != null) {
      _selectedPublisherId = widget.book!.publisherId;
    }

    // Use post-frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load categories and publishers using BLoC
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<PublisherBloc>().add(LoadPublishersEvent());
    });
  }

  Future<void> _handleRatingChanged(int bookId, int rating) async {
    try {
      // Use BLoC to rate the book
      context.read<BookBloc>().add(RateBook(bookId, rating));

      setState(() {
        _rating = rating.toDouble();
      });

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

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id,
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        publisher: _selectedPublisherName,
        publisherId: _selectedPublisherId,
        imageUrl: _imageUrl,
        category: _selectedCategoryId ?? 0 as String,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        roles: 1, // Default role for admin
      );

      // Use the onSave callback provided by the parent widget
      // This will use BLoC in the parent component
      widget.onSave(book);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  Future<void> _deleteBook() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      if (widget.book?.id != null) {
        // Use BLoC to delete the book
        context.read<BookBloc>().add(DeleteBook(widget.book!.id!));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Book deleted successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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

              // Category dropdown using BLoC
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state.status == CategoryStatus.loading) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text('Loading categories...'),
                      items: [],
                      onChanged: null,
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text('Select a category'),
                    isExpanded: true,
                    items:
                        state.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id?.toString(),
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        if (value != null) {
                          final category = state.categories.firstWhere(
                            (c) => c.id.toString() == value,
                            orElse:
                                () => CategoryModel(id: null, name: 'Unknown'),
                          );
                          _selectedCategoryName = category.name;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              // Publisher dropdown using BLoC
              BlocBuilder<PublisherBloc, PublisherState>(
                builder: (context, state) {
                  if (state is PublisherLoadingState) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Publisher',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text('Loading publishers...'),
                      items: [],
                      onChanged: null,
                    );
                  }

                  if (state is PublisherLoadedState) {
                    return DropdownButtonFormField<String>(
                      value: _selectedPublisherId,
                      decoration: InputDecoration(
                        labelText: 'Publisher',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text('Select a publisher'),
                      isExpanded: true,
                      items:
                          state.publishers.map((publisher) {
                            return DropdownMenuItem(
                              value: publisher.maNhaXuatBan?.toString(),
                              child: Text(publisher.tenNhaXuatBan ?? 'Unknown'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPublisherId = value;
                          if (value != null) {
                            final publisher = state.publishers.firstWhere(
                              (p) => p.maNhaXuatBan.toString() == value,
                              orElse:
                                  () => Publishermodels(
                                    maNhaXuatBan: 0,
                                    tenNhaXuatBan: 'Unknown',
                                  ),
                            );
                            _selectedPublisherName = publisher.tenNhaXuatBan;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a publisher';
                        }
                        return null;
                      },
                    );
                  }

                  // Error or initial state
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Publisher',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text('Failed to load publishers'),
                    items: [],
                    onChanged: null,
                  );
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