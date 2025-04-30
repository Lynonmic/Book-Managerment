import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/cart/order_details_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
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
}
