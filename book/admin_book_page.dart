import 'package:flutter/material.dart';
import 'package:frontend/widget/book_item.dart';

class BookPageAdmin extends StatefulWidget {
  const BookPageAdmin({Key? key}) : super(key: key);

  @override
  State<BookPageAdmin> createState() => _BookPageAdminState();
}

class _BookPageAdminState extends State<BookPageAdmin> {
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Book Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add new book functionality
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Book'),
                ),
              ],
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
                    // Handle book edit for admin
                    print('Admin editing book: ${book['title']}');
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          // Refresh book list
          setState(() {});
        },
      ),
    );
  }
}
