import 'package:flutter/material.dart';
import 'package:frontend/views/account/account_page.dart';
import 'package:frontend/views/book/book_page_admin.dart';
import 'package:frontend/views/cart/order_page.dart';
import 'package:frontend/views/search/search_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomMenuPage extends StatefulWidget {
  const BottomMenuPage({super.key});

  @override
  _BottomMenuPageState createState() => _BottomMenuPageState();
}

class _BottomMenuPageState extends State<BottomMenuPage> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

 final List<String> _titles = ["Book List", "Order List", "Search", "Customer List"];
  List<Widget> _buildScreens() {
    return [
      const BookPageAdmin(),
      const OrderPage(),
      const SearchPage(),
      const AccountPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(icon: Icon(Icons.home), title: "Home", activeColorPrimary: Colors.purpleAccent, inactiveColorPrimary: const Color.fromARGB(255, 69, 68, 68)),
      PersistentBottomNavBarItem(icon: Icon(Icons.shopping_cart), title: "Cart", activeColorPrimary: Colors.purpleAccent, inactiveColorPrimary: Color.fromARGB(255, 69, 68, 68)),
      PersistentBottomNavBarItem(icon: Icon(Icons.search), title: "Search", activeColorPrimary: Colors.purpleAccent, inactiveColorPrimary: Color.fromARGB(255, 69, 68, 68)),
      PersistentBottomNavBarItem(icon: Icon(Icons.person), title: "Profile", activeColorPrimary: Colors.purpleAccent, inactiveColorPrimary: Color.fromARGB(255, 69, 68, 68)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_controller.index]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "settings") {
                print("Settings selected");
              } else if (value == "logout") {
                print("Logout selected");
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "author",
                  child: Text("Author List"),
                ),
                const PopupMenuItem(
                  value: "customer",
                  child: Text("Customer List"),
                ),
                const PopupMenuItem(
                  value: "category",
                  child: Text("Category List"),
                ),
              ];
            },
          ),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarStyle: NavBarStyle.style3,
        onItemSelected: (index) {
          setState(() {});
        },
      ),
    );
  }
}
