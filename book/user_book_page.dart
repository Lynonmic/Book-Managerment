import 'package:flutter/material.dart';
import 'package:frontend/widget/book_item.dart';

class BookPageUser extends StatefulWidget {
  const BookPageUser({Key? key}) : super(key: key);

  @override
  State<BookPageUser> createState() => _BookPageUserState();
}

class _BookPageUserState extends State<BookPageUser> {
  // Sample data - in real app, this would come from an API or database
  final List<Map<String, dynamic>> _books = [
    {
      'title': 'Book Title 1',
      'description':
          'This is a description for the first book. It covers various topics and is quite interesting.',
      'rating': 4,
    },
    {
      'title': 'Book Title 2',
      'description':
          'This is a description for the second book. Its a bestseller in its category.',
      'rating': 5,
    },
    {
      'title': 'Book Title 3',
      'description':
          'This is a description for the third book. It explores advanced concepts.',
      'rating': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return BookItem(
                  title: book['title'],
                  description: book['description'],
                  rating: book['rating'],
                  onTap: () {
                    // Handle book details view for user
                    print('User viewing details of: ${book['title']}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
