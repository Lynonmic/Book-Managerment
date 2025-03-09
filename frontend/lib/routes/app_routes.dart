import 'package:flutter/material.dart';
import 'package:frontend/views/account/account_page.dart';
import 'package:frontend/views/cart/order_page.dart';
import 'package:frontend/views/search/search_page.dart';
import 'package:frontend/views/login/login_page.dart';
import 'package:frontend/views/bottom_menu_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String bottomMenu = '/bottomMenu';
  static const String cart = '/cart';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const LoginPage(),
      bottomMenu: (context) => const BottomMenuPage(),
      cart: (context) => const OrderPage(),
      search: (context) => const SearchPage(),
      profile: (context) => const AccountPage(),
    };
  }
}
