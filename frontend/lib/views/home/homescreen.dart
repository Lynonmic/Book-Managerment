import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/controllers/users_controller.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/service/books/book_services.dart';
import 'package:frontend/views/book/UI/book_item.dart';
import 'package:frontend/service/categories/category_provider.dart';
import 'package:frontend/views/book/admin_book_page.dart';
import 'package:frontend/views/book/user_watch_page.dart';
import 'package:frontend/views/cart/cart_page.dart'; // Add this import
import 'package:frontend/views/category/admin_category.dart';
import 'package:frontend/views/category/category_item.dart';
import 'package:frontend/views/category/edit_category_screen.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';
import 'package:frontend/views/profile/profile_page.dart';
import 'package:frontend/views/publisher/publisher_edit_page.dart';
import 'package:frontend/views/search/search_page.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/floating_button.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // ✅ Thêm userData

  const HomeScreen({super.key, required this.userData});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentItemType = 'books';

  // User-related variables
  List<UserModels> _users = [];
  bool _isloadUsers = false;
  String? _errorUsers;
  UsersController _usersController = UsersController();

  // Publisher-related variables
  List<Publishermodels> _publishers = [];
  bool _isLoadingPublishers = false;
  String? _errorPublisher;
  PublisherController _controller = PublisherController();

  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _usersController = UsersController(); // Initialize UsersController
    _controller = PublisherController(); // Initialize PublisherController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });

    _fetchUsers();
    _fetchPublishers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<BookProvider>(context, listen: false).fetchBooks();
      }
    });
  }

  // Rate a book
  Future<void> _rateBook(int bookId, double rating) async {
    try {
      await _bookService.rateBook(bookId, rating);
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  Future<void> _fetchUsers() async {
    print("===== _fetchUsers() is called =====");
    setState(() {
      _isloadUsers = true;
      _errorUsers = null;
    });

    try {
      final users = await _usersController.fetchUsers();
      print("===== _fetchUsers() got ${users.length} users =====");
      setState(() {
        _users = users;
        _isloadUsers = false;
      });
    } catch (e) {
      print("Fetch Users Error: $e");
      setState(() {
        _errorUsers = 'Failed to load users: $e';
        _isloadUsers = false;
      });
    }
  }

  Future<void> _fetchPublishers() async {
    setState(() {
      _isLoadingPublishers = true;
      _errorPublisher = null;
    });

    try {
      final publishers = await PublisherController().fetchPublishers();
      setState(() {
        _publishers = publishers;
        _isLoadingPublishers = false;
      });
    } catch (e) {
      setState(() {
        _errorPublisher = 'Failed to load publishers: $e';
        _isLoadingPublishers = false;
      });
    }
  }

  void _handleRatingChanged(int bookId, int rating) async {
    try {
      // Convert the integer rating to a double explicitly
      await Provider.of<BookProvider>(
        context,
        listen: false,
      ).rateBook(bookId, rating.toDouble());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted: $rating stars')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  void _handleOptionSelected(String value) {
    setState(() {
      _currentItemType = value;
      _currentIndex = 0;
      if (value == 'books') {
        // Fetch books list
        Provider.of<BookProvider>(context, listen: false).fetchBooks();
      }
      if (value == 'profile') {
        _currentItemType = 'profile';
      }

      if (value == 'search') {
        _currentItemType = 'search';
      }

      if (value == 'users') {
        // Fetch users list
        _fetchUsers();
      }
      if (value == 'publisher') {
        _fetchPublishers();
        // Fetch publishers list
      }
      if (value == 'categories') {
        // Fetch categories list
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      }
      if (value == 'ratings') {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        if (bookProvider._books.isNotEmpty) {
          final book = bookProvider._books.first;
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Rate Book: ${book.title}'),
                  content: InteractiveStarRating(
                    onRatingChanged: (rating) {
                      Navigator.pop(context);
                      if (book.id != null) {
                        _rateBook(book.id!, rating.toDouble());
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
          );
          _currentItemType = 'books';
        }
      }
    });
  }

  Widget _buildBookList() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (bookProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(bookProvider.error, style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => bookProvider.fetchBooks(isRetry: true),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (bookProvider.books.isEmpty) {
          return Center(child: Text('No books found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => bookProvider.refreshBooks(),
              child: ListView.builder(
                itemCount: bookProvider.books.length,
                itemBuilder: (context, index) {
                  final book = bookProvider.books[index];
                  return BookItem(
                    title: book.title,
                    description: book.description ?? 'No description available',
                    onTap: () {
                      if (book.roles != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider.value(
                                  value: Provider.of<BookProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  child: BookFormScreen(
                                    book: book,
                                    onSave: (updatedBook) async {
                                      final bookProvider =
                                          Provider.of<BookProvider>(
                                            context,
                                            listen: false,
                                          );

                                      try {
                                        if (updatedBook.id != null) {
                                          // Update existing book
                                          print(
                                            'Updating book with ID: ${updatedBook.id}',
                                          );
                                          final result = await bookProvider
                                              .updateBook(updatedBook);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Book updated successfully',
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        // Refresh books list whether successful or not
                                        bookProvider.fetchBooks();
                                      }
                                    },
                                  ),
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BookDetailScreen(
                                  book: {
                                    'id': book.id,
                                    'title': book.title,
                                    'author': book.author,
                                    'description': book.description,
                                    'imageUrl': book.imageUrl,
                                    'category': book.category,
                                  },
                                ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child:
                  _currentItemType == 'categories' || _currentIndex != 0
                      ? Container()
                      : FloatingButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BookFormScreen(
                                    onSave: (Book newBook) async {
                                      final bookProvider =
                                          Provider.of<BookProvider>(
                                            context,
                                            listen: false,
                                          );

                                      try {
                                        final result = await bookProvider
                                            .addBook(newBook);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Book added successfully',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        // Refresh the book list
                                        bookProvider.fetchBooks();
                                      }
                                    },
                                  ),
                            ),
                          );
                        },
                        tooltip: 'Add Book',
                        backgroundColor: Colors.blue,
                      ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToBookDetail(Book book) {
    print(
      'Navigating to book detail for: ${book.title} with roles: ${book.roles} and ID: ${book.id}',
    );

    try {
      if (book.roles == 1) {
        // Navigate to admin book page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChangeNotifierProvider.value(
                  value: Provider.of<BookProvider>(context, listen: false),
                  child: BookFormScreen(
                    book: book,
                    onSave: (updatedBook) async {
                      print(
                        'Book to update: ${updatedBook.id} - ${updatedBook.title}',
                      );
                      final bookProvider = Provider.of<BookProvider>(
                        context,
                        listen: false,
                      );

                      if (updatedBook.id != null) {
                        // Update existing book
                        print('Updating book with ID: ${updatedBook.id}');
                        final result = await bookProvider.updateBook(
                          updatedBook,
                        );
                        if (result != null) {
                          print('Book updated successfully');
                        } else {
                          print('Failed to update book: ${bookProvider.error}');
                        }
                      }

                      // Refresh the book list
                      bookProvider.fetchBooks();
                    },
                  ),
                ),
          ),
        );
      } else {
        // Navigate to user book page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookDetailScreen(
                  book: {
                    'id': book.id,
                    'title': book.title,
                    'author': book.author,
                    'description': book.description,
                    'imageUrl': book.imageUrl,
                  },
                ),
          ),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating to book details: $e')),
      );
    }
  }

  Widget _buildUserList() {
    if (_isloadUsers) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorUsers != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorUsers!,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy người dùng',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _editUser(user);
                },
                onLongPress: () {
                  _showDeleteConfirmationDialogUserList(context, user);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child:
                          user.urlAvata != null
                              ? Image.network(user.urlAvata!, fit: BoxFit.cover)
                              : Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                    ),
                  ),
                  title: Text(
                    user.tenKhachHang ?? "Không có tên",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.diaChi ?? "Không có địa chỉ",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        user.email ?? "Không có email",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editUser(user);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialogUserList(context, user);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'edit', child: Text("✏️ Sửa")),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Xóa",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPublisherList() {
    if (_isLoadingPublishers) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorPublisher != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorPublisher!,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPublishers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_publishers.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy nhà xuất bản',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: _publishers.length,
          itemBuilder: (context, index) {
            final publisher = _publishers[index];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _edit(publisher);
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(context, publisher);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    publisher.tenNhaXuatBan ?? "Không có tên",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    publisher.diaChi ?? "Không có địa chỉ",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _edit(publisher);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, publisher);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'edit', child: Text("✏️ Sửa")),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Xóa",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublisherEditPage(isEditing: false),
                ),
              );
              _fetchPublishers();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categoryProvider.error,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => categoryProvider.fetchCategories(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (categoryProvider.categories.isEmpty) {
          return Center(child: Text('No categories found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => categoryProvider.refreshCategories(),
              child: ListView.builder(
                itemCount: categoryProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  String displayName = "ID: ${category.id} - ${category.name}";
                  return CategoryItem(
                    name: displayName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditCategoryScreen(
                                category:
                                    category, // Pass CategoryModel directly
                              ),
                        ),
                      ).then((_) {
                        categoryProvider.fetchCategories();
                      });
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditCategoryScreen(
                            category: CategoryModel(
                              id: 0,
                              name: '',
                            ), // Pass empty CategoryModel for new category
                          ),
                    ),
                  ).then((_) {
                    // Refresh categories after adding new one
                    categoryProvider.fetchCategories();
                  });
                },
                child: Icon(Icons.add),
                tooltip: 'Add Category',
              ),
            ),
          ],
        );
      },
    );
  }

  // Update the title based on current index and item type
  String _getTitle() {
    if (_currentIndex == 0) {
      switch (_currentItemType) {
        case 'books':
          return 'Book List';
        case 'users':
          return 'User List';
        case 'publisher':
          return 'Publisher List';
        case 'profile':
          return 'Profile Page';
        case 'search':
          return 'Search Page';
        case 'categories':
          return 'Category List';
        default:
          return 'Book List';
      }
    } else {
      // Existing titles for other tabs
      switch (_currentIndex) {
        case 1:
          return 'Cart Page';
        case 2:
          return 'Search Page';
        case 3:
          return 'Profile Page';
        default:
          return 'Home';
      }
    }
  }

  void _showDeleteConfirmationDialogUserList(
    BuildContext context,
    UserModels user,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc chắn muốn xóa '${user.tenKhachHang}' không?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog trước khi xóa
                _deleteUser(user.maKhachHang!); // Chỉ gọi hàm xóa
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Publishermodels publisher,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc chắn muốn xóa '${publisher.tenNhaXuatBan}' không?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePublisher(publisher.maNhaXuatBan!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int userId) async {
    bool success = await _usersController.deleteUser(userId);

    if (success) {
      _users.removeWhere((user) => user.maKhachHang == userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ User đã được xóa thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Xóa thất bại. Vui lòng thử lại!"),
          backgroundColor: Colors.red,
        ),
      );
    }
    _fetchUsers();
  }

  void _deletePublisher(int maNhaXuatBan) async {
    final response = await _controller.deletePublisher(maNhaXuatBan);
    bool success = response['success'] ?? false;

    if (success) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xóa thất bại. Vui lòng thử lại!"),
          backgroundColor: Colors.red,
        ),
      );
    }
    _fetchPublishers();
  }

  void _edit(Publishermodels publisher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PublisherEditPage(
              isEditing: true,
              publisherData: {
                "maNhaXuatBan": publisher.maNhaXuatBan,
                "tenNhaXuatBan": publisher.tenNhaXuatBan,
                "diaChi": publisher.diaChi,
                "soDienThoai": publisher.soDienThoai,
                "email": publisher.email,
              },
            ),
      ),
    );

    _fetchPublishers();
  }

  void _editUser(UserModels user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              isEditing: true,
              userData: {
                "id": user.maKhachHang,
                "name": user.tenKhachHang,
                "address": user.diaChi,
                "phone": user.soDienThoai,
                "email": user.email,
                "avatar": user.urlAvata,
              },
            ),
      ),
    );
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_currentIndex == 0)
            OptionMenu(onOptionSelected: _handleOptionSelected),
        ],
      ),
      body:
          _currentIndex == 0
              ? (_currentItemType == 'books'
                  ? _buildBookList()
                  : _currentItemType == 'users'
                  ? _buildUserList()
                  : _currentItemType == 'publisher'
                  ? _buildPublisherList()
                  : _currentItemType == 'profile'
                  ? ProfilePage(userData: widget.userData)
                  : _currentItemType == 'search'
                  ? const SearchUserPage()
                  : _currentItemType == 'categories'
                  ? _buildCategoryList()
                  : Container())
              : _currentIndex == 1
              ? CartPage()
              : _currentIndex == 2
              ? const SearchUserPage()
              : _currentIndex == 3
              ? ProfilePage(userData: widget.userData)
              : Container(), // Plac
      bottomNavigationBar: BottomMenu(
        initialIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _error = '';

  List<Book> get books => _filteredBooks.isNotEmpty ? _filteredBooks : _books;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchBooks({bool isRetry = false}) async {
    _isLoading = true;
    if (!isRetry) _error = '';
    notifyListeners();

    try {
      final bookService = BookService();
      final fetchedBooks = await bookService.fetchBooks();
      _books = fetchedBooks;
      _filteredBooks = [];
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBooks() async {
    return fetchBooks(isRetry: true);
  }

  Future<Book?> updateBook(Book book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bookService = BookService();
      final updatedBook = await bookService.updateBook(book);
      return updatedBook;
    } catch (e) {
      _error = 'Failed to update book: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Book?> addBook(Book book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bookService = BookService();
      final createdBook = await bookService.createBook(book);
      return createdBook;
    } catch (e) {
      _error = 'Failed to add book: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rateBook(int bookId, double rating) async {
    try {
      final bookService = BookService();
      await bookService.rateBook(bookId, rating);
      await fetchBooks();
      return true;
    } catch (e) {
      _error = 'Failed to rate book: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bookService = BookService();
      final success = await bookService.deleteBook(bookId);
      if (success) {
        // Remove the book from the local list
        _books.removeWhere((book) => book.id == bookId);
        _error = '';
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete book: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(int categoryId) {
    _filteredBooks =
        _books.where((book) => book.category == categoryId).toList();
    notifyListeners();
  }
}
