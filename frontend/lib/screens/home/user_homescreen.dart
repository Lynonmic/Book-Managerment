import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/book/book_bloc.dart';
import 'package:frontend/blocs/book/book_event.dart';
import 'package:frontend/blocs/book/book_state.dart';
import 'package:frontend/blocs/category/category_bloc.dart';
import 'package:frontend/blocs/category/category_event.dart';
import 'package:frontend/blocs/evaluation/evaluation_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_event.dart';
import 'package:frontend/blocs/order/order_bloc.dart';
import 'package:frontend/blocs/order/order_event.dart';
import 'package:frontend/blocs/publisher/publisher_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_event.dart';
import 'package:frontend/blocs/search/search_user_bloc.dart';
import 'package:frontend/blocs/search/search_user_event.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/blocs/user/user_event.dart';
import 'package:frontend/screens/book/UI/book_item_user.dart';
import 'package:frontend/screens/book/user_book_page.dart';
import 'package:frontend/screens/cart/cart_page.dart';
import 'package:frontend/screens/evaluation/evaluation_list.dart';
import 'package:frontend/screens/profile/profile_page.dart';
import 'package:frontend/screens/search/search_page.dart';
import 'package:frontend/screens/widget/bottom_menu.dart';
import 'package:frontend/screens/widget/option_menu_user.dart';

class UserHomescreen extends StatefulWidget {
  final Map<String, dynamic> userData; //

  const UserHomescreen({super.key, required this.userData});

  @override
  _UserHomescreen createState() => _UserHomescreen();
}

class _UserHomescreen extends State<UserHomescreen> {
  int _currentIndex = 0;
  String _currentItemType = 'books';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load initial data using BLoCs
      context.read<BookBloc>().add(LoadBooks());
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<OrderBloc>().add(FetchOrders());
      context.read<UserBloc>().add(LoadUsersEvent());
      context.read<PublisherBloc>().add(LoadPublishersEvent());
      context.read<EvaluationBloc>().add(LoadAllReviews());
      context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
    });
  }

  void _handleOptionSelected(String value) {
    setState(() {
      if (value == 'books') {
        _currentItemType = 'books';
        context.read<BookBloc>().add(LoadBooks());
      } else if (value == 'profile') {
        _currentItemType = 'profile';
      } else if (value == 'search') {
        _currentItemType = 'search';
        context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
      } else if (value == 'evaluations') {
        _currentItemType = 'evaluations';
        context.read<EvaluationBloc>().add(LoadAllReviews());
      } else if (value == 'cart') {
        _currentItemType = 'cart';
      }
    });
  }

  Widget _buildBookList() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state.status == BookStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.status == BookStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'An error occurred',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<BookBloc>().add(LoadBooks()),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.books.isEmpty) {
          return Center(child: Text('No books found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<BookBloc>().add(LoadBooks());
            return Future.delayed(Duration(milliseconds: 300));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: state.books.length,
              itemBuilder: (context, index) {
                final book = state.books[index];
                return BookItemUser(
                  title: book.title,
                  imageUrl:
                      book.imageUrl ?? 'assets/images/baythoiquenthanhdat.jpg',
                  price: book.price ?? 0,
                  rating: 0.0,
                  category: book.category ?? 'Unknown',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserBookPage(book: book),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvaluationList() {
    return const EvaluationListScreen();
  }

  // Update the title based on current index and item type
  String _getTitle() {
    switch (_currentItemType) {
      case 'books':
        return 'Book Management';
      case 'profile':
        return 'Profile';
      case 'search':
        return 'Search';
      case 'cart':
        return 'Cart Management';
      case 'evaluations':
        return 'Reviews Management';
      default:
        return 'Book Management';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // 👉 Căn giữa tiêu đề
        title: Text(_getTitle()),
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _currentItemType = 'search';
              _currentIndex = 0;
              context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
            });
          },
        ),
        actions: [
          if (_currentIndex ==
              0) // Chỉ hiển thị OptionMenu khi đang ở tab 'books'
            OptionMenuUser(onOptionSelected: _handleOptionSelected),
        ],
      ),
      body:
          _currentIndex == 0
              ? (_currentItemType == 'books'
                  ? _buildBookList()
                  : _currentItemType == 'profile'
                  ? ProfilePage(userData: widget.userData)
                  : _currentItemType == 'search'
                  ? const SearchUserPage()
                  : _currentItemType == 'evaluations'
                  ? _buildEvaluationList()
                  : _currentItemType == 'cart'
                  ? CartPage()
                  : Container())
              : _currentIndex == 1
              ? CartPage()
              : _currentIndex == 2
              ? const SearchUserPage()
              : _currentIndex == 3
              ? ProfilePage(userData: widget.userData)
              : Container(),
      bottomNavigationBar: BottomMenu(
        initialIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;

            if (_currentIndex == 0) {
              _currentItemType = 'books';
            } else if (_currentIndex == 1) {
              _currentItemType = 'cart';
            } else if (_currentIndex == 2) {
              _currentItemType = 'search';
            } else if (_currentIndex == 3) {
              _currentItemType = 'profile';
            }
          });
        },
      ),
    );
  }
}
