import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/blocs/user/user_event.dart';
import 'package:frontend/blocs/user/user_state.dart';
import 'package:frontend/blocs/book/book_bloc.dart';
import 'package:frontend/blocs/book/book_event.dart';
import 'package:frontend/blocs/book/book_state.dart';
import 'package:frontend/model/UserModels.dart'; // Ensure this matches your model file
import 'package:frontend/model/book_model.dart';
import 'package:frontend/screens/cart/order_details_page.dart';
import 'package:frontend/screens/widget/floating_button.dart';
import 'package:http/http.dart' as http; // Ensure this matches your model file

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true; // Keep this for loading orders initially
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Fetch orders still uses http directly for now, or refactor it to use an OrderBloc if available
    _fetchOrders();
    // Dispatch events to load users and books
    context.read<UserBloc>().add(LoadUsersEvent());
    context.read<BookBloc>().add(LoadBooks());
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle various response formats
        if (data is List) {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else if (data is Map) {
          // If it's a single object or has a data property containing the array
          if (data.containsKey('data') && data['data'] is List) {
            setState(() {
              _orders = List<Map<String, dynamic>>.from(data['data']);
              _isLoading = false;
            });
          } else {
            // It's a single order object
            setState(() {
              _orders = [Map<String, dynamic>.from(data)];
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _error = 'Unexpected response format';
            _isLoading = false;
          });
        }

        print('Orders processed: ${_orders.length}');
        print(
          'First order (if any): ${_orders.isNotEmpty ? _orders.first : "None"}',
        );
      } else {
        setState(() {
          _error = 'Failed to load orders: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching orders: $e';
        _isLoading = false;
      });
      print('Error fetching orders: $e');
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      // Replace with your actual API endpoint
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/orders/$orderId/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order cancelled successfully')));
        _fetchOrders(); // Refresh the orders
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel order')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Format date string to a more readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Get appropriate color for order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'chờ xử lý':
        return Colors.orange;
      case 'đã xử lý':
        return Colors.green;
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingButton(
        onPressed: () {
          _showCreateOrderDialog(context);
        },
        tooltip: 'Create Order',
        backgroundColor: Colors.purple,
        icon: Icons.add_shopping_cart,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchOrders,
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              )
              : _orders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You have no orders',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to home/books tab
                        Navigator.of(context).pop();
                      },
                      child: Text('Browse Books'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Your Orders (${_orders.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        // Debug the order structure
                        print('Rendering order at index $index: $order');

                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order['id'] ?? 'Unknown ID'}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          order['status'] ?? '',
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        order['status'] ?? 'Unknown Status',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      order['customerName'] ??
                                          'Unknown Customer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Date: ${_formatDate(order['orderDate'] ?? '')}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Total: \$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                if (order['items'] != null &&
                                    (order['items'] as List).isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: Image.asset(
                                              'assets/images/baythoiquenthanhdat.jpg',
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Icon(
                                                  Icons.book,
                                                  color: Colors.grey[600],
                                                  size: 24,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${(order['items'] as List).length} items in this order',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: Icon(Icons.visibility),
                                      label: Text('View Details'),
                                      onPressed: () {
                                        // Navigate to OrderDetailsPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => OrderDetailsPage(
                                                  orderId: order['id'],
                                                  customerName:
                                                      order['customerName'] ??
                                                      'Unknown',
                                                ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                    if (order['status']?.toLowerCase() ==
                                        'chờ xử lý')
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.cancel_outlined),
                                        label: Text('Cancel Order'),
                                        onPressed: () {
                                          _cancelOrder(order['id']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  // Method to show the create order dialog
  void _showCreateOrderDialog(BuildContext context) {
    UserModels? selectedCustomer; // Use UserModels type
    Book? selectedBook; // Use Book type
    int quantity = 1;
    List<Map<String, dynamic>> orderItems = [];
    double totalAmount = 0.0;

    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final customerAddressController = TextEditingController();

    // Function to update total amount
    void updateTotalAmount() {
      totalAmount = orderItems.fold(0.0, (sum, item) {
        final price =
            item['price'] as num? ?? 0; // Ensure price is treated as num
        final qty = item['quantity'] as int? ?? 0; // Ensure quantity is int
        return sum + (price * qty);
      });
      // No need to call setState here if totalAmount is only used within the dialog's stateful builder
    }

    // Helper function to update customer details (optional, but good practice)
    void updateCustomerDetails(UserModels customer) {
      selectedCustomer = customer;
      customerNameController.text = customer.tenKhachHang ?? 'N/A';
      customerPhoneController.text = customer.soDienThoai ?? '';
      customerAddressController.text = customer.diaChi ?? '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage dialog's internal state like selected items
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Order'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // User Dropdown using BlocBuilder
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        if (state is UserLoading) {
                          return const CircularProgressIndicator();
                        } else if (state is UserLoaded) {
                          // Ensure selectedCustomer is still valid if users list reloads
                          if (selectedCustomer != null &&
                              !state.users.any(
                                (u) =>
                                    u.maKhachHang ==
                                    selectedCustomer!.maKhachHang,
                              )) {
                            selectedCustomer =
                                null; // Reset if previous selection is gone
                          }
                          return DropdownButtonFormField<UserModels>(
                            value: selectedCustomer,
                            hint: const Text('Select Customer'),
                            isExpanded: true,
                            items:
                                state.users.map((UserModels user) {
                                  return DropdownMenuItem<UserModels>(
                                    value: user,
                                    child: Text(
                                      user.tenKhachHang ?? 'Unnamed User',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (UserModels? newValue) {
                              setDialogState(() {
                                // Use setDialogState here
                                if (newValue != null) {
                                  updateCustomerDetails(newValue);
                                }
                              });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a customer'
                                        : null,
                          );
                        } else if (state is UserError) {
                          return Text('Error: ${state.message}');
                        }
                        return const Text('Select Customer'); // Initial/default
                      },
                    ),
                    TextField(
                      controller: customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                      ),
                      readOnly:
                          true, // Make read-only if populated from dropdown
                    ),
                    TextField(
                      controller: customerPhoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      readOnly: true,
                    ),
                    TextField(
                      controller: customerAddressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Order Items',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Book Dropdown using BlocBuilder
                    BlocBuilder<BookBloc, BookState>(
                      builder: (context, state) {
                        if (state.status == BookStatus.loading) {
                          return const CircularProgressIndicator();
                        } else if (state.status == BookStatus.loaded) {
                          // Ensure selectedBook is valid if book list reloads
                          if (selectedBook != null &&
                              !state.books.any(
                                (b) => b.id == selectedBook!.id,
                              )) {
                            selectedBook = null; // Reset
                          }
                          return DropdownButtonFormField<Book>(
                            value: selectedBook,
                            hint: const Text('Select Book'),
                            isExpanded: true,
                            items:
                                state.books.map((Book book) {
                                  return DropdownMenuItem<Book>(
                                    value: book,
                                    child: Text(
                                      '${book.title} (\$${book.price?.toStringAsFixed(2) ?? 'N/A'})',
                                    ), // Corrected escaping
                                  );
                                }).toList(),
                            onChanged: (Book? newValue) {
                              setDialogState(() {
                                // Use setDialogState
                                selectedBook = newValue;
                              });
                            },
                          );
                        } else if (state.status == BookStatus.error) {
                          return Text('Error: ${state.errorMessage}');
                        }
                        return const Text('Select Book');
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              quantity = int.tryParse(value) ?? 1;
                            },
                            controller: TextEditingController(
                              text: '1',
                            ), // Default qty
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            if (selectedBook != null) {
                              setDialogState(() {
                                // Use setDialogState
                                orderItems.add({
                                  'bookId': selectedBook!.id,
                                  'bookTitle': selectedBook!.title,
                                  'quantity': quantity,
                                  'price':
                                      selectedBook!.price ??
                                      0.0, // Use price from Book model
                                });
                                updateTotalAmount(); // Recalculate total
                                // Optionally reset selectedBook and quantity for next item
                                // selectedBook = null;
                                // quantity = 1;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Display Added Items
                    SizedBox(
                      height: 150, // Constrain height
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          final price = item['price'] as num? ?? 0;
                          return ListTile(
                            title: Text(item['bookTitle'] ?? 'Unknown Book'),
                            subtitle: Text(
                              'Qty: ${item['quantity']} @ \$${price.toStringAsFixed(2)}',
                            ), // Corrected escaping
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  // Use setDialogState
                                  orderItems.removeAt(index);
                                  updateTotalAmount();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display Total Amount Dynamically
                    Text(
                      'Total: \$${totalAmount.toStringAsFixed(2)}', // Corrected escaping
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCustomer == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a customer'),
                        ),
                      );
                      return;
                    }
                    if (orderItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add at least one item'),
                        ),
                      );
                      return;
                    }

                    // Use selectedCustomer data
                    // Adjust based on your UserModels ID field (assuming it's int?)
                    String customerId =
                        selectedCustomer!.maKhachHang?.toString() ?? '';
                    String customerName =
                        selectedCustomer!.tenKhachHang ?? 'Unknown';

                    _createOrder(
                      customerId,
                      customerName, // Use name from selected customer
                      customerPhoneController.text,
                      customerAddressController.text,
                      totalAmount,
                      orderItems,
                    );
                    Navigator.pop(context); // Close dialog
                  },
                  child: const Text('Create Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Create a new order with the API
  Future<void> _createOrder(
    String customerId,
    String customerName,
    String phone,
    String address,
    double totalAmount,
    List<Map<String, dynamic>> orderItems,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Prepare order data (for orders table)
      final orderData = {
        'customerId': customerId,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'status': 'Chờ xử lý',
        'orderDate': DateTime.now().toIso8601String(),
        'totalAmount': totalAmount,
        // Include order items for the backend to process
        'orderDetails':
            orderItems
                .map(
                  (item) => {
                    'bookId': item['bookId'],
                    'bookTitle': item['bookTitle'],
                    'quantity': item['quantity'],
                    'price': item['price'],
                  },
                )
                .toList(),
      };

      // Send the combined data to the API
      // The backend should handle splitting this into orders and order_details tables
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse the response to get the created order ID
        final responseData = json.decode(response.body);
        String orderId = 'Unknown';

        if (responseData is Map && responseData.containsKey('id')) {
          orderId = responseData['id'].toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #$orderId created successfully')),
        );

        // Refresh the orders list
        _fetchOrders();
      } else {
        setState(() {
          _isLoading = false;
        });

        // Try to parse error message from response
        String errorMessage = 'Failed to create order: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating order: $e')));
    }
  }
}
