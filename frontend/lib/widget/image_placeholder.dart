// lib/widgets/image_picker.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BookImagePicker extends StatefulWidget {
  final String? imageUrl;
  final Function(String?) onImageSelected;

  const BookImagePicker({
    Key? key,
    this.imageUrl,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  State<BookImagePicker> createState() => _BookImagePickerState();
}

class _BookImagePickerState extends State<BookImagePicker> {
  final ImagePicker _picker = ImagePicker();
  String? _localImagePath;
  bool _isNetworkImage = false;

  @override
  void initState() {
    super.initState();
    _localImagePath = widget.imageUrl;
    _isNetworkImage =
        widget.imageUrl != null &&
        (widget.imageUrl!.startsWith('http://') ||
            widget.imageUrl!.startsWith('https://'));
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localImagePath = image.path;
        _isNetworkImage = false;
      });
      widget.onImageSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _localImagePath != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      _isNetworkImage
                          ? Image.network(
                            _localImagePath!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Error loading image',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                          : Image.file(
                            File(_localImagePath!),
                            fit: BoxFit.cover,
                          ),
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tap to select image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
