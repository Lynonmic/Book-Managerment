import 'package:flutter/material.dart';
import 'package:your_project/views/login/login_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String cart = '/cart';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {home: (context) => const HomePage()};
  }
}
