import 'package:flutter/material.dart';
import 'package:frontend/views/account/profile_admin_page.dart';
import 'package:frontend/views/account/user_list_page.dart';
import 'package:frontend/views/book/book_page_admin.dart';
import 'package:frontend/views/cart/order_page.dart';
import 'package:frontend/views/category/category_list_page.dart';
import 'package:frontend/views/publisher/publisher_list_page.dart';
import 'package:frontend/views/search/search_page.dart';

class BottomMenuPage extends StatefulWidget {
  const BottomMenuPage({super.key});

  @override
  _BottomMenuPageState createState() => _BottomMenuPageState();
}

class _BottomMenuPageState extends State<BottomMenuPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _titles = ["Book List", "Order List", "Search", "Profile"];
  final List<Widget> _screens = [
    const BookPageAdmin(),
    const OrderPage(),
    const SearchPage(),
    const ProfileAdminPage(),
  ];

  void _onMenuSelected(String value) {
    Navigator.pop(context); // Đóng menu trước khi mở trang mới
    Future.delayed(Duration.zero, () {
      if (value == "publisher") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PublisherListPage()));
      } else if (value == "user") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListPage()));
      } else if (value == "category") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryListPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: "publisher", child: Text("Publisher List")),
                const PopupMenuItem(value: "user", child: Text("User List")),
                const PopupMenuItem(value: "category", child: Text("Category List")),
              ];
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
