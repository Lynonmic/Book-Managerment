import 'package:flutter/material.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/views/book/user_watch_page.dart';
import 'package:frontend/views/book/admin_book_page.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:provider/provider.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/views/home/homescreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BookProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
      routes: {
        '/user_book_page':
            (context) => Scaffold(
              appBar: AppBar(title: const Text('User Book Page')),
              body: const BookDetailScreen(),
            ),
        '/user_watch_page':
            (context) => BookDetailScreen(
              book: null, // You can pass book data from the navigation later
              onBack: () => Navigator.pop(context),
            ),
        '/admin_book_page':
            (context) => BookFormScreen(
              book: null, // You can pass book data from the navigation later
              onSave: (book) {
                // Save book data
                Navigator.pop(context);
              },
            ),
      },
    );
  }
}
