import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/controllers/users_controller.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/book_service.dart';
import 'package:frontend/views/book/user_book_page.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';
import 'package:frontend/views/publisher/publisher_edit_page.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/floating_button.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';

void main() {
  runApp(const MyApp());
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
              appBar: AppBar(title: Text('User Book Page')),
              body: const BookPageUser(),
            ),
      },
    );
  }
}

// Example screen that uses the BottomMenu
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Track currently displayed item type
  String _currentItemType = 'books'; // Default to books

  // Service for API calls
  final BookService _bookService = BookService();
  final PublisherController _controller = PublisherController();
  final UsersController _usersController = UsersController();

  // State variables to hold API data
  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchUsers();
  }

  // Fetch books from API
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load books: $e';
        _isLoading = false;
      });
    }
  }

  // Rate a book
  Future<void> _rateBook(int bookId, double rating) async {
    try {
      await _bookService.rateBook(bookId, rating);
      // Refresh the book list after rating
      _fetchBooks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  List<UserModels> _users = [];
  bool _isloadUsers = false;
  String? _errorUsers;
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

  List<Publishermodels> _publishers = [];
  bool _isLoadingPublishers = false;
  String? _errorPublisher;

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

  final List<Widget> _pages = [
    const Center(child: Text('Cart Page')),
    const Center(child: Text('Cart Page')),
    const Center(child: Text('Search Page')),
    const Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which content to show based on navigation index
    Widget mainContent;

    if (_currentIndex == 0) {
      // Show items based on selection when on the home tab
      mainContent = _buildItemList();
    } else {
      // Use the existing pages for other tabs
      mainContent = _pages[_currentIndex];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          OptionMenu(
            onOptionSelected: (value) {
              _handleOptionSelected(context, value);
            },
            tooltip: 'More options',
          ),
        ],
      ),
      body: mainContent,
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

  // Build the appropriate item list based on current selection
  Widget _buildItemList() {
    switch (_currentItemType) {
      case 'books':
        return _buildBookList();
      case 'users':
        return _buildUserList();
      case 'publisher':
        return _buildPublisherList();
      default:
        return _buildBookList();
    }
  }

  // Build book list
  Widget _buildBookList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchBooks, child: Text('Try Again')),
          ],
        ),
      );
    }

    if (_books.isEmpty) {
      return Center(child: Text('No books found'));
    }

    return RefreshIndicator(
      onRefresh: _fetchBooks,
      child: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return BookItem(
            title: book.title,
            description: book.description ?? 'No description available',
            rating: book.rating?.round() ?? 0,
            onTap: () {
              // Show book details with rating option
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(book.title),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (book.imageUrl != null)
                            Image.network(
                              book.imageUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, error, _) => Container(
                                    height: 150,
                                    color: Colors.grey.shade300,
                                    child: Icon(Icons.image, size: 50),
                                  ),
                            ),
                          SizedBox(height: 16),
                          Text('Publisher: ${book.author}'),
                          SizedBox(height: 8),
                          Text(
                            'Rating: ${book.rating?.toStringAsFixed(1) ?? 'Not rated'} (${book.ratingCount ?? 0} reviews)',
                          ),
                          SizedBox(height: 16),
                          Text('Rate this book:'),
                          SizedBox(height: 8),
                          InteractiveStarRating(
                            onRatingChanged: (rating) {
                              Navigator.pop(context);
                              _rateBook(book.id!, rating.toDouble());
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          );
        },
      ),
    );
  }

  // Build user list - placeholder since we're focusing on books
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
          child: FloatingButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublisherEditPage(isEditing: false),
                ),
              );
              _fetchPublishers();
            },
          ),
        ),
      ],
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

    bool success = await _usersController.deleteUser(
      userId
    );

    if (success) {
      setState(() {
        _users.removeWhere((user) => user.maKhachHang == userId);
      });

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
  }

  void _deletePublisher(int maNhaXuatBan) async {

    final response = await _controller.deletePublisher(maNhaXuatBan);
    bool success = response['success'] ?? false;

    if (success) {
      setState(() {
        _publishers.removeWhere((p) => p.maNhaXuatBan == maNhaXuatBan);
      });
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xóa thất bại. Vui lòng thử lại!"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    if (result == true) {
      _fetchUsers();
    }
  }

  // Handle option menu selection
  void _handleOptionSelected(BuildContext context, String value) {
    // Update the current item type
    setState(() {
      _currentItemType = value;
      // Make sure we're on the first tab to see the items
      _currentIndex = 0;
      if (value == 'users') {
        _fetchUsers(); // Gọi API lấy danh sách publisher
      }
      if (value == 'publisher') {
        _fetchPublishers(); // Gọi API lấy danh sách publisher
      }
      // If selecting ratings, show a dialog to rate a book
      if (value == 'ratings' && _books.isNotEmpty) {
        final book =
            _books.first; // Just an example, could show a list to select from
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
        _currentItemType = 'books'; // Reset to books view after rating
      }
    });
  }
}
