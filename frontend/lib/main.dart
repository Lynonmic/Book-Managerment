import 'package:flutter/material.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/service/categories/category_provider.dart';
import 'package:frontend/views/home/homescreen.dart';
import 'package:frontend/views/login/login_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/views/category/admin_category.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MyApp(),
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
      home: const LoginPage(),
    );
  }
}
