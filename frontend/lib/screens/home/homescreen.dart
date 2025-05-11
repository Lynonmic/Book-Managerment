import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/book/book_bloc.dart';
import 'package:frontend/blocs/book/book_event.dart';
import 'package:frontend/blocs/book/book_state.dart';
import 'package:frontend/blocs/category/category_bloc.dart';
import 'package:frontend/blocs/category/category_event.dart';
import 'package:frontend/blocs/category/category_state.dart';
import 'package:frontend/blocs/evaluation/evaluation_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_event.dart';
import 'package:frontend/blocs/evaluation/evaluation_state.dart';
import 'package:frontend/blocs/order/order_bloc.dart';
import 'package:frontend/blocs/order/order_event.dart';
import 'package:frontend/blocs/position/position_bloc.dart';
import 'package:frontend/blocs/position/position_event.dart';
import 'package:frontend/blocs/publisher/publisher_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_event.dart';
import 'package:frontend/blocs/publisher/publisher_state.dart';
import 'package:frontend/blocs/search/search_user_bloc.dart';
import 'package:frontend/blocs/search/search_user_event.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/blocs/user/user_event.dart';
import 'package:frontend/blocs/user/user_state.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/screens/book/UI/book_item.dart';
import 'package:frontend/screens/book/add_position.dart';
import 'package:frontend/screens/book/admin_book_page.dart';
import 'package:frontend/screens/cart/order_page.dart';
import 'package:frontend/screens/profile/edit_profile_page.dart';
import 'package:frontend/screens/profile/profile_page.dart';
import 'package:frontend/screens/publisher/publisher_edit_page.dart';
import 'package:frontend/screens/search/search_page.dart';
import 'package:frontend/screens/widget/bottom_menu.dart';
import 'package:frontend/screens/widget/floating_button.dart';
import 'package:frontend/screens/widget/option_menu.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData; 

  const HomeScreen({super.key, required this.userData});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentItemType = 'books';
  List<Book>? _filteredBooks;

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
      context.read<PositionBloc>().add(FetchPositionFields());
    });
  }

  // Rate a book
  Future<void> _rateBook(int bookId, double rating) async {
    try {
      context.read<BookBloc>().add(RateBook(bookId, rating.toInt()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted: ${rating.toInt()} stars')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rate book: $e')));
    }
  }

  void _handleRatingChanged(int bookId, int rating) async {
    try {
      context.read<BookBloc>().add(RateBook(bookId, rating));
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
      if (value == 'books') {
        _currentItemType = 'books';
        context.read<BookBloc>().add(LoadBooks());
      } else if (value == 'users') {
        _currentItemType = 'users';
        context.read<UserBloc>().add(LoadUsersEvent());
      } else if (value == 'publisher') {
        _currentItemType = 'publisher';
        context.read<PublisherBloc>().add(LoadPublishersEvent());
      } else if (value == 'profile') {
        _currentItemType = 'profile';
      } else if (value == 'search') {
        _currentItemType = 'search';
        context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
      } else if (value == 'categories') {
        _currentItemType = 'categories';
        context.read<CategoryBloc>().add(LoadCategories());
      }else if (value == 'positions') {
        _currentItemType = 'positions';
      } else if (value == 'evaluations') {
        _currentItemType = 'evaluations';
        context.read<EvaluationBloc>().add(LoadAllReviews());
        context.read<UserBloc>().add(LoadUsersEvent());
      } else if (value == 'add_book') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookFormScreen(onSave: (Book newBook) {}),
          ),
        );
      } else if (value == 'edit_profile') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    EditProfilePage(userData: widget.userData, isEditing: true),
          ),
        );
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

        return Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (query) {
                      // Filter books based on search query
                      final filteredBooks = state.books.where((book) {
                        return book.title.toLowerCase().contains(query.toLowerCase());
                      }).toList();
                      
                      // Update the displayed books
                      setState(() {
                        _filteredBooks = filteredBooks;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookBloc>().add(LoadBooks());
                      return Future.delayed(Duration(milliseconds: 300));
                    },
                    child: ListView.builder(
                      itemCount: _filteredBooks?.length ?? state.books.length,
                      itemBuilder: (context, index) {
                        final book = _filteredBooks?[index] ?? state.books[index];
                        return BookItem(
                          title: book.title,
                          description: book.description ?? 'No description available',
                          imageUrl: book.imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookFormScreen(
                                  book: book,
                                  onSave: (updatedBook) async {
                                    try {
                                      if (updatedBook.id != null) {
                                        // Update existing book using BLoC
                                        context.read<BookBloc>().add(
                                          UpdateBook(updatedBook),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Book updated successfully'),
                                          ),
                                        );
                                      }
                                    } finally {
                                      // Refresh books list
                                      context.read<BookBloc>().add(LoadBooks());
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
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
                                      try {
                                        // Add book using BLoC
                                        context.read<BookBloc>().add(
                                          AddBook(newBook),
                                        );
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
                                        context.read<BookBloc>().add(
                                          LoadBooks(),
                                        );
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

  Widget _buildEvaluationList() {
    return BlocBuilder<EvaluationBloc, EvaluationState>(
      builder: (context, state) {
        // Check the status enum field
        if (state.status == EvaluationStatus.loading) {
          return Center(child: CircularProgressIndicator());
        } else if (state.status == EvaluationStatus.loaded) {
          // Access the list from state.reviews
          final evaluations = state.reviews;

          if (evaluations.isEmpty) {
            return Center(child: Text('No evaluations available'));
          }

          return ListView.builder(
            itemCount: evaluations.length,
            itemBuilder: (context, index) {
              final evaluation = evaluations[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Text(
                        evaluation.bookTitle ?? 'Unknown Book',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      _buildRatingStars(evaluation.rating),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('By: ${evaluation.userName ?? 'Anonymous'}'),
                      SizedBox(height: 4),
                      Text(evaluation.comment ?? 'No comment'),
                      SizedBox(height: 4),
                      Text(
                        'Date: ${evaluation.createdAt != null ? evaluation.createdAt!.toString().substring(0, 10) : 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Implement edit functionality
                        // _showEditEvaluationDialog(context, evaluation);
                      } else if (value == 'delete') {
                        // Implement delete functionality
                        // _showDeleteEvaluationConfirmationDialog(context, evaluation);
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
          // Check the status enum field
        } else if (state.status == EvaluationStatus.error) {
          return Center(
            child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
          );
        } else {
          // Handles EvaluationStatus.initial
          return Center(child: Text('No evaluations available'));
        }
      },
    );
  }

  Widget _buildRatingStars(int? rating) {
    final int starCount = rating ?? 0;
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is UserError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(LoadUsersEvent());
                  },
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

        if (state is UserLoaded) {
          final users = state.users;

          if (users.isEmpty) {
            return Center(
              child: Text(
                'Không tìm thấy người dùng',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

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
                                ? Image.network(
                                  user.urlAvata!,
                                  fit: BoxFit.cover,
                                )
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          user.email ?? "Không có email",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
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
          );
        }

        return SizedBox(); // fallback nếu không khớp state
      },
    );
  }

  Widget _buildPublisherList() {
    return BlocBuilder<PublisherBloc, PublisherState>(
      builder: (context, state) {
        if (state is PublisherLoadingState || state is PublisherInitialState) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is PublisherErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PublisherBloc>().add(LoadPublishersEvent());
                  },
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

        if (state is PublisherLoadedState) {
          final publishers = state.publishers;

          if (publishers.isEmpty) {
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
                itemCount: publishers.length,
                itemBuilder: (context, index) {
                  final publisher = publishers[index];

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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
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
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text("✏️ Sửa"),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
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
                        builder:
                            (context) => PublisherEditPage(isEditing: false),
                      ),
                    );
                    if (result == true) {
                      context.read<PublisherBloc>().add(LoadPublishersEvent());
                    }
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          );
        }

        return SizedBox(); // fallback nếu không match state
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.read<CategoryBloc>().add(
                    AddCategory(
                      CategoryModel(id: null, name: nameController.text.trim()),
                    ),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Category added')));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final TextEditingController nameController = TextEditingController(
      text: category.name,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.read<CategoryBloc>().add(
                    UpdateCategory(
                      CategoryModel(
                        id: category.id,
                        name: nameController.text.trim(),
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Category updated')));
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteCategoryConfirmationDialog(context, category);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryConfirmationDialog(
    BuildContext context,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CategoryBloc>().add(DeleteCategory(category.id!));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Category deleted')));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.status == CategoryStatus.error) {
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
                  onPressed:
                      () => context.read<CategoryBloc>().add(LoadCategories()),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.categories.isEmpty) {
          return Center(child: Text('No categories found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<CategoryBloc>().add(LoadCategories());
                return Future.delayed(Duration(milliseconds: 300));
              },
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  String displayName = "ID: ${category.id} - ${category.name}";
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _showEditCategoryDialog(context, category);
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _showAddCategoryDialog(context);
                },
                tooltip: 'Add Category',
                child: Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  // Update the title based on current index and item type
  String _getTitle() {
    switch (_currentItemType) {
      case 'books':
        return 'Book Management';
      case 'users':
        return 'User Management';
      case 'publisher':
        return 'Publisher Management';
      case 'profile':
        return 'Profile';
      case 'search':
        return 'Search';
      case 'categories':
        return 'Category Management';
      case 'orders':
        return 'Order Management';
      case 'positions':
        return 'Position Management';
      case 'evaluations':
        return 'Reviews Management';
      default:
        return 'Book Management';
    }
  }

  void _showDeleteConfirmationDialogUserList(
    BuildContext context,
    UserModels user,
  ) {
    _showDeleteDialog(
      context: context,
      title: "Xác nhận xóa",
      content: "Bạn có chắc chắn muốn xóa '${user.tenKhachHang}' không?",
      onConfirm: () => _deleteUser(user.maKhachHang!),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Publishermodels publisher,
  ) {
    _showDeleteDialog(
      context: context,
      title: "Xác nhận xóa",
      content: "Bạn có chắc chắn muốn xóa '${publisher.tenNhaXuatBan}' không?",
      onConfirm: () => _deletePublisher(publisher.maNhaXuatBan!),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
                onConfirm();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int userId) {
    context.read<UserBloc>().add(DeleteUserEvent(userId));
  }

  void _deletePublisher(int maNhaXuatBan) {
    context.read<PublisherBloc>().add(
      DeletePublisherEvent(maNhaXuatBan: maNhaXuatBan),
    );
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
    context.read<PublisherBloc>().add(LoadPublishersEvent());
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
    context.read<UserBloc>().add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_currentIndex ==
              0) // Chỉ hiển thị OptionMenu khi đang ở tab 'books'
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
                  : _currentItemType == 'evaluations'
                  ? _buildEvaluationList()
                  : _currentItemType == 'positions'
                  ? AddPositionFieldScreen()
                  : Container()
                      as Widget) // Ensure this branch returns a Widget
              : _currentIndex == 1
              ? OrderPage() as Widget
              : _currentIndex == 2
              ? const SearchUserPage() as Widget
              : _currentIndex == 3
              ? ProfilePage(userData: widget.userData) as Widget
              : SizedBox.shrink(),
      bottomNavigationBar: BottomMenu(
        initialIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;

            if (_currentIndex == 0) {
              _currentItemType = 'books';
            } else if (_currentIndex == 1) {
              _currentItemType = 'orders';
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
