import 'package:flutter/material.dart';
import '../../widget/bottom_menu.dart';
import '../../widget/book_item.dart';

class BookPageAdmin extends StatefulWidget {
  const BookPageAdmin({super.key});

  @override
  State<BookPageAdmin> createState() => _BookPageAdminState();
}

class _BookPageAdminState extends State<BookPageAdmin> {
  int _selectedOptionIndex = 0;
  int _selectedNavIndex = 0;

  // Sample book data
  final List<Map<String, dynamic>> _books = [
    {
      'title': 'The Great Gatsby',
      'description': 'A novel by F. Scott Fitzgerald',
      'rating': 4,
      'imageUrl': 'https://example.com/greatgatsby.jpg',
    },
    {
      'title': 'To Kill a Mockingbird',
      'description': 'A novel by Harper Lee',
      'rating': 5,
      'imageUrl': 'https://example.com/mockingbird.jpg',
    },
    {
      'title': '1984',
      'description': 'A dystopian novel by George Orwell',
      'rating': 4,
      'imageUrl': 'https://example.com/1984.jpg',
    },
    {
      'title': 'Pride and Prejudice',
      'description': 'A romantic novel by Jane Austen',
      'rating': 5,
      'imageUrl': 'https://example.com/pride.jpg',
    },
    {
      'title': 'The Hobbit',
      'description': 'A fantasy novel by J.R.R. Tolkien',
      'rating': 4,
      'imageUrl': 'https://example.com/hobbit.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.purpleAccent,
        actions: [
          // Three dots menu
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (index) {
              setState(() {
                _selectedOptionIndex = index;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 0, child: Text('Books')),
                  const PopupMenuItem(value: 1, child: Text('Authors')),
                  const PopupMenuItem(value: 2, child: Text('Users')),
                ],
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomMenu(
        currentIndex: _selectedNavIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_selectedOptionIndex) {
      case 0:
        return "Books Management";
      case 1:
        return "Authors Management";
      case 2:
        return "Users Management";
      default:
        return "Admin Dashboard";
    }
  }

  Widget _buildContent() {
    // Show different content based on selected option
    switch (_selectedOptionIndex) {
      case 0: // Books
        return ListView.builder(
          itemCount: _books.length,
          itemBuilder: (context, index) {
            final book = _books[index];
            return BookItem(
              title: book['title'],
              description: book['description'],
              rating: book['rating'],
              imageUrl: book['imageUrl'],
              imageSize: 60,
              starColor: Colors.purpleAccent,
              onTap: () {
                // Handle book item tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${book['title']}')),
                );
              },
            );
          },
        );
      case 1: // Authors
        return const Center(child: Text('Authors section coming soon!'));
      case 2: // Users
        return const Center(child: Text('Users section coming soon!'));
      default:
        return const SizedBox.shrink();
    }
  }
}
