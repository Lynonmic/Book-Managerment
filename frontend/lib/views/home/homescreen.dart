import 'package:flutter/material.dart';
import 'package:frontend/controllers/publisher_controller.dart';
import 'package:frontend/controllers/users_controller.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/service/books/book_provider.dart';
import 'package:frontend/service/books/book_services.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';
import 'package:frontend/views/publisher/publisher_edit_page.dart';
import 'package:frontend/widget/book_item.dart';
import 'package:frontend/widget/bottom_menu.dart';
import 'package:frontend/widget/floating_button.dart';
import 'package:frontend/widget/option_menu.dart';
import 'package:frontend/widget/rating_star.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentItemType = 'books';
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  // User-related variables
  List<UserModels> _users = [];
  bool _isloadUsers = false;
  String? _errorUsers;
  late UsersController _usersController;

  // Publisher-related variables
  List<Publishermodels> _publishers = [];
  bool _isLoadingPublishers = false;
  String? _errorPublisher;
  late PublisherController _controller;

  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchUsers();
    _fetchPublishers();
    // Initialize other necessary elements
  }

  // Fetch books from API
  Future<void> _fetchBooks() async {
    print("===== _fetchBooks() is called =====");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _bookService.fetchBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
      print("===== _fetchBooks() got ${books.length} books =====");
    } catch (e) {
      print("Fetch Users Error: $e");
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
        // Fetch users list
        _fetchBooks();
      }
      if (value == 'users') {
        // Fetch users list
        _fetchUsers();
      }
      if (value == 'publisher') {
        _fetchPublishers();
        // Fetch publishers list
      }
      if (value == 'ratings') {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        if (bookProvider.books.isNotEmpty) {
          final book = bookProvider.books.first;
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
                  onPressed: () => bookProvider.fetchBooks(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (bookProvider.books.isEmpty) {
          return Center(child: Text('No books found'));
        }

        return RefreshIndicator(
          onRefresh: () => bookProvider.refreshBooks(),
          child: ListView.builder(
            itemCount: bookProvider.books.length,
            itemBuilder: (context, index) {
              final book = bookProvider.books[index];
              return BookItem(
                title: book.title,
                description: book.description ?? 'No description available',
                rating:
                    book.rating?.round() ??
                    0, // This is correct, but ensure BookItem accepts this as int
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
                              Text('Author: ${book.author}'),
                              SizedBox(height: 8),
                              Text(
                                'Rating: ${book.rating?.toStringAsFixed(1) ?? 'Not rated'} (${book.ratingCount ?? 0} reviews)',
                              ),
                              SizedBox(height: 16),
                              Text('Rate this book:'),
                              SizedBox(height: 8),
                              InteractiveStarRating(
                                onRatingChanged: (rating) async {
                                  Navigator.pop(context);
                                  try {
                                    if (book.id != null) {
                                      // Ensure conversion to double
                                      await Provider.of<BookProvider>(
                                        context,
                                        listen: false,
                                      ).rateBook(book.id!, rating.toDouble());

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Rating submitted: $rating stars',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to rate book: $e',
                                        ),
                                      ),
                                    );
                                  }
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
      },
    );
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
              ? _currentItemType == 'books'
                  ? _buildBookList()
                  : _currentItemType == 'users'
                  ? _buildUserList()
                  : _buildPublisherList()
              : Container(), // Other tabs implementation
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
