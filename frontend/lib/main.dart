import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/controllers/users_controller.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/service/books/book_services.dart';
import 'package:frontend/views/book/user_watch_page.dart';
import 'package:frontend/views/home/homescreen.dart';
import 'package:frontend/views/login/login_page.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';
import 'package:frontend/views/publisher/publisher_edit_page.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/floating_button.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        // Other providers if any
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
