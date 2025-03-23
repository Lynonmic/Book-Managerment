// book_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/widget/backbutton_and_title.dart';
import 'package:frontend/widget/image_placeholder.dart';
import 'package:frontend/widget/primary_button.dart';
import 'package:frontend/widget/rating_star.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? book;
  final VoidCallback? onBack;

  const BookDetailScreen({super.key, this.book, this.onBack});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  String? _imageUrl;

  final PageController _pageController = PageController();

  void _handleEdit() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Edit book content")));
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this book?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Book deleted")));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Sharing book...")));
  }

  void _showCategoryOptions(BuildContext context, String categoryTitle) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleShare();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const AppHeader(title: 'Book', subtitle: 'Watch'),
              Expanded(
                child: SingleChildScrollView(
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category section with three-dots menu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thể Loại',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_horiz),
                                  onPressed:
                                      () => _showCategoryOptions(
                                        context,
                                        'Thể Loại',
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Scrollable category pills
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: const [
                                  CategoryPill(
                                    label: 'Hài hước',
                                    isActive: true,
                                  ),
                                  CategoryPill(
                                    label: 'Lãng mạn',
                                    isActive: false,
                                  ),
                                  CategoryPill(
                                    label: 'Hàng động',
                                    isActive: false,
                                  ),
                                  CategoryPill(
                                    label: 'Section',
                                    isActive: false,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Row Header',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              'Body copy description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            InteractiveStarRating(
                              maxRating: 5,
                              color: Colors.amber,
                              size: 24,
                              onRatingChanged: (rating) {
                                // Handle the rating change
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Rated $rating stars'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Page content with horizontal scrolling
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: PrimaryButton(
                label: 'Quay về',
                onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A simple CategoryPill widget for the horizontal list
class CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;

  const CategoryPill({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.black : Colors.grey[200],
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
