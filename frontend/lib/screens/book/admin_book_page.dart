import 'dart:developer';
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
import 'package:frontend/model/posotionField_model.dart';
import 'package:frontend/repositories/position_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/screens/widget/primary_button.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/category_model.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;
  final Future<int> Function(Book) onSave;

  const BookFormScreen({Key? key, this.book, required this.onSave})
    : super(key: key);

  @override
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Book>? _filteredBooks;
  List<PositionFieldModel> _positionFields = [];
  Map<int, TextEditingController> _positionControllers = {};

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
  bool _isUploading = false;
  bool _isDeleting = false;

  // State for categories and publishers
  List<CategoryModel> _categories = [];
  List<String> _selectedCategoryIds = []; // << Re-add state for multiple IDs
  String? _dropdownSelectedCategoryId; // << Re-add state for dropdown value

  // Publisher-related state
  int? _selectedPublisherId;
  String? _selectedPublisherName;
  List<Publishermodels> _publishers = [];

  @override
  void initState() {
    super.initState();
    _loadPositionFields();
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
      text: widget.book?.publisherId?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.book?.quantity?.toString() ?? '0',
    );

    _imageUrl = widget.book?.imageUrl;

    _selectedCategoryIds =
        widget.book?.category?.split(',').map((id) => id.trim()).toList() ??
        []; // Initialize selected categories

    // Set the selected publisher ID and name if editing a book
    if (widget.book?.publisherId != null) {
      _selectedPublisherId = widget.book!.publisherId;
      _selectedPublisherName = widget.book!.publisherName;
      // Initialize publisher name from the book
    }
    print(_selectedPublisherName);
    // Use post-frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load categories and publishers using BLoC
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<PublisherBloc>().add(LoadPublishersEvent());
    });
  }

  Future<void> _loadPositionFields() async {
    try {
      final data = await PositionRepo.getPositionFields(); // GỌI REPO

      setState(() {
        _positionFields = List<PositionFieldModel>.from(
          data.map((item) => PositionFieldModel.fromJson(item)),
        );
        for (var field in _positionFields) {
          _positionControllers[field.id] = TextEditingController();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải các trường vị trí: $e')),
      );
    }
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
          _isUploading = true; // Set uploading flag to true
        });

        // Upload image to Cloudinary
        try {
          // Use the BLoC to upload the image
          context.read<BookBloc>().add(UploadImage(_imageFile!));

          // Listen for the result
          // We'll handle this in the build method with a BlocListener
        } catch (uploadError) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $uploadError')),
          );
        }
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
      // Check if we're still uploading an image
      if (_isUploading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please wait for image upload to complete')),
        );
        return;
      }

      String? finalImageUrl = _imageUrl;
      log('Saving book with image URL: $finalImageUrl');

      final tenDanhMucString =
          _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.join(',');

      final book = Book(
        id: widget.book?.id,
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        publisherName: _selectedPublisherName,
        publisherId: _selectedPublisherId,
        imageUrl: finalImageUrl,
        category: tenDanhMucString,
        quantity: int.tryParse(_quantityController.text) ?? 0,
      );

      try {
        final bookId = await widget.onSave(book);
        log('Book saved with ID: $bookId');

        // Lưu vị trí sách với bookId đã có
        log('Saving positions for bookId: $bookId');
        for (var field in _positionFields) {
          final value = _positionControllers[field.id]?.text ?? '';
          log('Field: ${field.name}, Value: $value');
          if (value.isNotEmpty) {
            log(
              'Adding position: bookId=$bookId, fieldId=${field.id}, positionValue=$value',
            );
            await PositionRepo.addBookPosition(bookId, field.id, value);
          }
          Navigator.pop(context); // Trở lại màn hình trước
        }
      } catch (e) {
        log('Error saving book or position: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
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
    return MultiBlocListener(
      listeners: [
        BlocListener<BookBloc, BookState>(
          listener: (context, state) {
            // Handle image upload response
            if (state.status == BookStatus.loaded &&
                state.uploadedImageUrl != null) {
              setState(() {
                _imageUrl = state.uploadedImageUrl;
                _isUploading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image uploaded successfully')),
              );
            } else if (state.status == BookStatus.error && _isUploading) {
              setState(() {
                _isUploading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error uploading image: ${state.errorMessage}'),
                ),
              );
            }
          },
        ),
        // Add a listener for PublisherBloc to initialize publisher name when publishers are loaded
        BlocListener<PublisherBloc, PublisherState>(
          listener: (context, state) {
            if (state is PublisherLoadedState &&
                _selectedPublisherId != null &&
                (_selectedPublisherName == null ||
                    _selectedPublisherName!.isEmpty)) {
              // Find the publisher name based on ID
              final publisher = state.publishers.firstWhere(
                (p) => p.maNhaXuatBan.toString() == _selectedPublisherId,
                orElse:
                    () => Publishermodels(
                      maNhaXuatBan: 0,
                      tenNhaXuatBan: 'Unknown',
                    ),
              );
              setState(() {
                _selectedPublisherName = publisher.tenNhaXuatBan;
              });
            }
          },
        ),
      ],
      child: BlocListener<BookBloc, BookState>(
        listener: (context, state) {
          // Empty listener - actual logic moved to MultiBlocListener above
        },
        child: Scaffold(
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
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state.status == CategoryStatus.loading) {
                        // Show disabled dropdown while loading
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Add Category',
                            border: OutlineInputBorder(),
                          ),
                          hint: Text('Loading categories...'),
                          items: [],
                          onChanged: null, // Disable interaction
                        );
                      }

                      // Only build dropdown if categories loaded successfully
                      if (state.status == CategoryStatus.loaded) {
                        // << Use loaded instead of success
                        return DropdownButtonFormField<String>(
                          value:
                              _dropdownSelectedCategoryId, // Use a separate state for dropdown value
                          decoration: InputDecoration(
                            labelText: 'Add Category', // Changed label
                            border: OutlineInputBorder(),
                          ),
                          hint: Text('Select a category to add'),
                          isExpanded: true,
                          items:
                              state.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.id?.toString(),
                                  // Disable item if already selected
                                  enabled:
                                      !_selectedCategoryIds.contains(
                                        category.id.toString(),
                                      ),
                                  child: Text(
                                    category.name,
                                    style:
                                        !_selectedCategoryIds.contains(
                                              category.id.toString(),
                                            )
                                            ? null
                                            : TextStyle(
                                              color: Colors.grey,
                                            ), // Grey out if selected
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null &&
                                  !_selectedCategoryIds.contains(value)) {
                                _selectedCategoryIds.add(
                                  value,
                                ); // Add to the list
                                _dropdownSelectedCategoryId =
                                    null; // Reset dropdown after selection
                              } else if (value != null) {
                                // Optional: Provide feedback if category is already selected
                                final categoryName =
                                    state.categories
                                        .firstWhere(
                                          (c) => c.id.toString() == value,
                                        )
                                        .name;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Category "$categoryName" already selected',
                                    ),
                                  ),
                                );
                                _dropdownSelectedCategoryId =
                                    null; // Reset dropdown
                              }
                            });
                          },
                          // No validator needed for 'Add' button usually
                        );
                      }

                      // Handle failure case
                      if (state.status == CategoryStatus.error) {
                        // << Use error instead of failure
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Add Category',
                            border: OutlineInputBorder(),
                            errorText: 'Failed to load categories',
                          ),
                          hint: Text('Error loading'),
                          items: [],
                          onChanged: null,
                        );
                      }

                      // Default empty state
                      return SizedBox.shrink();
                    },
                  ),

                  SizedBox(height: 16),

                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      String displayText;
                      bool isLoading =
                          state.status == CategoryStatus.loading ||
                          state.status == CategoryStatus.initial;
                      bool isError = state.status == CategoryStatus.error;

                      if (isLoading) {
                        if (_selectedCategoryIds.isEmpty) {
                          displayText = 'None (Loading categories...)';
                        } else {
                          // Show IDs while loading names
                          displayText =
                              'IDs: ${_selectedCategoryIds.join(', ')} (Loading names...)';
                        }
                      } else if (state.status == CategoryStatus.loaded) {
                        if (_selectedCategoryIds.isEmpty) {
                          displayText = 'None';
                        } else {
                          // Find category names based on selected IDs
                          final selectedCategoryNames = _selectedCategoryIds
                              .map((id) {
                                final category = state.categories.firstWhere(
                                  (cat) => cat.id.toString() == id,
                                  orElse:
                                      () => CategoryModel(
                                        id: null,
                                        name: 'Unknown ($id)',
                                      ), // Handle case where ID might not be found
                                );
                                return category.name;
                              })
                              .join(', ');
                          displayText = selectedCategoryNames;
                        }
                      } else {
                        // Error state
                        if (_selectedCategoryIds.isEmpty) {
                          displayText = 'Error loading categories';
                        } else {
                          // Show IDs even on error, but indicate error
                          displayText =
                              'IDs: ${_selectedCategoryIds.join(', ')} (Error loading names)';
                        }
                      }

                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Selected Categories',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16.0,
                          ),
                          // Show error text directly in the decorator if there's an error loading names
                          errorText:
                              isError ? 'Failed to load category names' : null,
                        ),
                        child: Text(displayText),
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
                        // If editing an existing book and publisher ID is available, set the selected value
                        if (widget.book != null &&
                            widget.book!.publisherId != null &&
                            _selectedPublisherId == null) {
                          _initializePublisherSelection(
                            state.publishers,
                            widget.book!.publisherId
                                ?.toString(), // Thêm toString()
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedPublisherId?.toString(),
                          decoration: InputDecoration(
                            labelText: 'Publisher',
                            border: OutlineInputBorder(),
                          ),
                          hint: Text(
                            _selectedPublisherName.toString() ??
                                'Select a publisher',
                          ),
                          isExpanded: true,
                          items:
                              state.publishers.map((publisher) {
                                return DropdownMenuItem(
                                  value: publisher.maNhaXuatBan?.toString(),
                                  child: Text(
                                    publisher.tenNhaXuatBan ?? 'Unknown',
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPublisherId =
                                  value != null
                                      ? int.parse(value)
                                      : null; // Chuyển String thành int
                              if (value != null) {
                                _selectedPublisherName = _findPublisherName(
                                  state.publishers,
                                  value,
                                );
                              }
                            });
                          },
                          validator: (value) {
                            // Only validate if no publisher is selected and this is a new book
                            // For existing books, the publisher should already be set
                            if ((value == null || value.isEmpty) &&
                                widget.book == null) {
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
                  Text(
                    'Location Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  ..._positionFields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(
                        controller: _positionControllers[field.id],
                        decoration: InputDecoration(
                          labelText: field.name,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập ${field.name.toLowerCase()}';
                          }
                          return null;
                        },
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 16),
                  // Save Button
                  PrimaryButton(label: 'Save Book', onPressed: _saveBook),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to find publisher name by ID
  String _findPublisherName(
    List<Publishermodels> publishers,
    String publisherId,
  ) {
    final publisher = publishers.firstWhere(
      (p) => p.maNhaXuatBan.toString() == publisherId,
      orElse: () => Publishermodels(maNhaXuatBan: 0, tenNhaXuatBan: 'Unknown'),
    );
    return publisher.tenNhaXuatBan ?? 'Unknown';
  }

  // Helper method to initialize publisher selection when editing a book
  void _initializePublisherSelection(
    List<Publishermodels> publishers,
    String? publisherId,
  ) {
    if (publisherId != null) {
      setState(() {
        _selectedPublisherId =
            publisherId != null
                ? int.parse(publisherId)
                : null; // Chuyển String thành int
        _selectedPublisherName = _findPublisherName(publishers, publisherId);
      });
    }
  }

  // Helper method to find publisher name by ID

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      // Show picked image file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Check if it's a network URL (http or https)
      if (_imageUrl!.startsWith('http') || _imageUrl!.startsWith('https')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading network image in form: $_imageUrl - $error');
              return Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              );
            },
          ),
        );
      } else {
        // Assume it's an asset path (though unlikely in this context now)
        // Consider adding better handling if local assets are still expected here
        return Image.asset(
          'assets/images/$_imageUrl', // Assuming asset path if not URL
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image in form: $_imageUrl - $error');
            return Center(child: Icon(Icons.error_outline, color: Colors.grey));
          },
        );
      }
    } else {
      // Placeholder when no image file or URL is available
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
